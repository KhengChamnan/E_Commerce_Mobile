<?php

namespace App\Http\Controllers;

use App\Models\Order;
use App\Models\Payment;
use App\Services\StripeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class PaymentController extends Controller
{
    protected $stripeService;
    
    public function __construct(StripeService $stripeService)
    {
        $this->stripeService = $stripeService;
    }
    
    /**
     * Create a payment intent for Stripe
     */
    public function createIntent($orderId)
    {
        $user = Auth::user();
        $order = Order::where('id', $orderId)
                ->where('user_id', $user->id)
                ->where('payment_status', 'unpaid')
                ->first();
                
        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found or already paid'
            ], 404);
        }
        
        // Create a payment intent
        $paymentIntent = $this->stripeService->createPaymentIntent($order);
        
        if (!$paymentIntent['success']) {
            return response()->json([
                'success' => false,
                'message' => $paymentIntent['message']
            ], 400);
        }
        
        return response()->json([
            'success' => true,
            'client_secret' => $paymentIntent['client_secret'],
            'payment_intent_id' => $paymentIntent['payment_intent_id'],
            'publishable_key' => config('services.stripe.key')
        ]);
    }
    
    /**
     * Handle Stripe webhook events
     */
    public function handleWebhook(Request $request)
    {
        $payload = $request->getContent();
        $sigHeader = $request->header('Stripe-Signature');
        
        $result = $this->stripeService->handleWebhookEvent($payload, $sigHeader);
        
        return response()->json($result);
    }
    
    /**
     * Checkout success page redirect
     */
    public function success(Request $request)
    {
        $orderId = $request->input('order_id');
        $order = Order::find($orderId);
        
        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Payment successful',
            'order' => $order
        ]);
    }
    
    /**
     * Checkout failure page redirect
     */
    public function failed(Request $request)
    {
        $orderId = $request->input('order_id');
        $order = Order::find($orderId);
        
        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Payment failed',
            'order' => $order
        ]);
    }
}