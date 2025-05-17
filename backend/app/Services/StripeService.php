<?php

namespace App\Services;

use App\Models\Order;
use App\Models\Payment;
use Illuminate\Support\Facades\Log;
use Stripe\Stripe;
use Stripe\PaymentIntent;
use Stripe\Exception\ApiErrorException;
use Stripe\Webhook;

class StripeService
{
    public function __construct()
    {
        // Get the Stripe secret key from config
        $stripeSecret = config('services.stripe.secret');
        
        // Check if the API key is set
        if (empty($stripeSecret)) {
            Log::error('Stripe API key is missing. Check your environment configuration.');
            throw new \Exception('Stripe API key is missing. Check your .env file and make sure STRIPE_SECRET is set.');
        }
        
        // Initialize Stripe with your secret key
        Stripe::setApiKey($stripeSecret);
    }
    
    /**
     * Create a Stripe payment intent
     */
    public function createPaymentIntent(Order $order)
    {
        try {
            $paymentIntent = PaymentIntent::create([
                'amount' => $this->formatAmountForStripe($order->total_amount),
                'currency' => 'usd', // Change as needed
                'metadata' => [
                    'order_id' => $order->id,
                    'order_number' => $order->order_number
                ],
                // Only use automatic_payment_methods since it conflicts with payment_method_types
                'automatic_payment_methods' => [
                    'enabled' => true,
                    'allow_redirects' => 'never'  // Prevent redirect flows
                ]
            ]);
            
            return [
                'success' => true,
                'client_secret' => $paymentIntent->client_secret,
                'payment_intent_id' => $paymentIntent->id
            ];
        } catch (ApiErrorException $e) {
            Log::error('Stripe payment intent creation failed: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Handle Stripe webhook events
     */
    public function handleWebhookEvent($payload, $sigHeader)
    {
        try {
            $event = Webhook::constructEvent(
                $payload,
                $sigHeader,
                config('services.stripe.webhook_secret')
            );
            
            Log::info('Stripe webhook received: ' . $event->type);
            
            // Handle the event based on its type
            switch ($event->type) {
                case 'payment_intent.succeeded':
                    return $this->handleSuccessfulPayment($event->data->object);
                
                case 'payment_intent.payment_failed':
                    return $this->handleFailedPayment($event->data->object);
                    
                case 'charge.succeeded':
                    Log::info('Charge succeeded: ' . $event->data->object->id);
                    return ['success' => true, 'message' => 'Charge recorded'];
                    
                case 'charge.refunded':
                    return $this->handleRefund($event->data->object);
                    
                case 'payment_intent.canceled':
                    return $this->handleCanceledPayment($event->data->object);
                    
                default:
                    Log::info('Unhandled Stripe event: ' . $event->type);
                    return ['success' => true, 'message' => 'Unhandled event'];
            }
        } catch (\UnexpectedValueException $e) {
            Log::error('Webhook error: Invalid payload: ' . $e->getMessage());
            return ['success' => false, 'message' => 'Invalid payload'];
        } catch (\Stripe\Exception\SignatureVerificationException $e) {
            Log::error('Webhook error: Invalid signature: ' . $e->getMessage());
            return ['success' => false, 'message' => 'Invalid signature'];
        }
    }
    
    /**
     * Handle successful payment
     */
    private function handleSuccessfulPayment($paymentIntent)
    {
        $orderId = $paymentIntent->metadata->order_id ?? null;
        
        if (!$orderId) {
            Log::error('Payment success but no order ID in metadata');
            return ['success' => false, 'message' => 'No order ID found'];
        }
        
        $order = Order::find($orderId);
        
        if (!$order) {
            Log::error('Payment success but order not found: ' . $orderId);
            return ['success' => false, 'message' => 'Order not found'];
        }
        
        // Update order status
        $order->payment_status = 'paid';
        $order->status = 'processing';
        $order->transaction_id = $paymentIntent->id;
        $order->save();
        
        // Create payment record
        Payment::create([
            'order_id' => $order->id,
            'transaction_id' => $paymentIntent->id,
            'amount' => $this->formatAmountFromStripe($paymentIntent->amount),
            'currency' => $paymentIntent->currency,
            'payment_method' => 'stripe',
            'status' => 'success',
            'response_data' => (array) $paymentIntent
        ]);
        
        Log::info('Payment successful for order: ' . $order->order_number);
        return ['success' => true, 'message' => 'Payment successful', 'order' => $order];
    }
    
    /**
     * Handle failed payment
     */
    private function handleFailedPayment($paymentIntent)
    {
        $orderId = $paymentIntent->metadata->order_id ?? null;
        
        if (!$orderId) {
            Log::error('Payment failed but no order ID in metadata');
            return ['success' => false, 'message' => 'No order ID found'];
        }
        
        $order = Order::find($orderId);
        
        if (!$order) {
            Log::error('Payment failed but order not found: ' . $orderId);
            return ['success' => false, 'message' => 'Order not found'];
        }
        
        // Update order status
        $order->payment_status = 'failed';
        $order->save();
        
        // Create payment record
        Payment::create([
            'order_id' => $order->id,
            'transaction_id' => $paymentIntent->id,
            'amount' => $this->formatAmountFromStripe($paymentIntent->amount),
            'currency' => $paymentIntent->currency,
            'payment_method' => 'stripe',
            'status' => 'failed',
            'response_data' => (array) $paymentIntent
        ]);
        
        Log::info('Payment failed for order: ' . $order->order_number);
        return ['success' => true, 'message' => 'Payment failure recorded', 'order' => $order];
    }
    
    /**
     * Handle refund events
     */
    private function handleRefund($charge)
    {
        $paymentIntentId = $charge->payment_intent;
        
        // Find the payment by transaction_id (payment_intent_id)
        $payment = Payment::where('transaction_id', $paymentIntentId)->first();
        
        if (!$payment) {
            Log::error('Refund event received but payment not found: ' . $paymentIntentId);
            return ['success' => false, 'message' => 'Payment not found'];
        }
        
        $order = Order::find($payment->order_id);
        
        if (!$order) {
            Log::error('Refund processed but order not found: ' . $payment->order_id);
            return ['success' => false, 'message' => 'Order not found'];
        }
        
        // Update order status
        $order->status = 'refunded';
        $order->save();
        
        // Create a refund record
        Payment::create([
            'order_id' => $order->id,
            'transaction_id' => $charge->id,
            'amount' => $this->formatAmountFromStripe($charge->amount_refunded),
            'currency' => $charge->currency,
            'payment_method' => 'stripe',
            'status' => 'refund',
            'response_data' => (array) $charge
        ]);
        
        Log::info('Refund processed for order: ' . $order->order_number);
        return ['success' => true, 'message' => 'Refund processed', 'order' => $order];
    }
    
    /**
     * Handle canceled payment intents
     */
    private function handleCanceledPayment($paymentIntent)
    {
        $orderId = $paymentIntent->metadata->order_id ?? null;
        
        if (!$orderId) {
            Log::error('Payment canceled but no order ID in metadata');
            return ['success' => false, 'message' => 'No order ID found'];
        }
        
        $order = Order::find($orderId);
        
        if (!$order) {
            Log::error('Payment canceled but order not found: ' . $orderId);
            return ['success' => false, 'message' => 'Order not found'];
        }
        
        // Update order status
        $order->payment_status = 'canceled';
        $order->status = 'canceled';
        $order->save();
        
        // Create payment record
        Payment::create([
            'order_id' => $order->id,
            'transaction_id' => $paymentIntent->id,
            'amount' => $this->formatAmountFromStripe($paymentIntent->amount),
            'currency' => $paymentIntent->currency,
            'payment_method' => 'stripe',
            'status' => 'canceled',
            'response_data' => (array) $paymentIntent
        ]);
        
        Log::info('Payment canceled for order: ' . $order->order_number);
        return ['success' => true, 'message' => 'Payment cancellation recorded', 'order' => $order];
    }
    
    /**
     * Add payment method to a customer
     */
    public function addPaymentMethod($customerId, $paymentMethodId)
    {
        try {
            // Attach the payment method to the customer
            $paymentMethod = \Stripe\PaymentMethod::retrieve($paymentMethodId);
            $paymentMethod->attach(['customer' => $customerId]);
            
            // Set as default payment method
            \Stripe\Customer::update($customerId, [
                'invoice_settings' => [
                    'default_payment_method' => $paymentMethodId
                ]
            ]);
            
            return [
                'success' => true,
                'message' => 'Payment method added successfully'
            ];
        } catch (ApiErrorException $e) {
            Log::error('Failed to add payment method: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => $e->getMessage()
            ];
        }
    }
    
    /**
     * Format the amount for Stripe (in cents)
     */
    private function formatAmountForStripe($amount)
    {
        // Stripe requires amounts in cents
        return (int) ($amount * 100);
    }
    
    /**
     * Format the amount from Stripe (from cents)
     */
    private function formatAmountFromStripe($amount)
    {
        // Convert from cents to dollars
        return $amount / 100;
    }
    
    /**
     * Log detailed error information
     */
    private function logStripeError(ApiErrorException $e)
    {
        $error = $e->getError();
        $errorData = [
            'type' => $error->type ?? 'unknown',
            'code' => $error->code ?? 'unknown',
            'param' => $error->param ?? 'none',
            'message' => $e->getMessage()
        ];
        
        Log::error('Stripe error: ', $errorData);
        return $errorData;
    }
}