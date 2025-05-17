<?php

namespace App\Http\Controllers;

use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use App\Services\StripeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class OrderController extends Controller
{
    protected $stripeService;
    
    public function __construct(StripeService $stripeService)
    {
        $this->stripeService = $stripeService;
    }
    
    /**
     * Get all orders for the authenticated user
     */
    public function index()
    {
        $user = Auth::user();
        $orders = Order::where('user_id', $user->id)
                 ->with('items', 'payment')
                 ->orderBy('created_at', 'desc')
                 ->get();
                 
        return response()->json([
            'status' => true,
            'orders' => $orders
        ]);
    }
    
    /**
     * Get a specific order
     */
    public function show($id)
    {
        $user = Auth::user();
        $order = Order::where('id', $id)
                ->where('user_id', $user->id)
                ->with('items', 'payment')
                ->first();
                
        if (!$order) {
            return response()->json([
                'status' => false,
                'message' => 'Order not found'
            ], 404);
        }
        
        return response()->json([
            'status' => true,
            'order' => $order
        ]);
    }
    
    /**
     * Create a new order from cart
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'shipping_address' => 'required|string',
            'phone' => 'required|string'
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $user = Auth::user();
        $cart = Cart::with(['items.product'])->where('user_id', $user->id)->first();
        
        if (!$cart || count($cart->items) == 0) {
            return response()->json([
                'status' => false,
                'message' => 'Cart is empty'
            ], 422);
        }
        
        // Calculate total amount
        $totalAmount = 0;
        foreach ($cart->items as $item) {
            $totalAmount += $item->product->price * $item->quantity;
        }
        
        // Add shipping cost
        $shippingCost = 1.35; // This could be configurable or calculated based on address
        
        // Create order
        $order = Order::create([
            'user_id' => $user->id,
            'order_number' => Order::generateOrderNumber(),
            'total_amount' => $totalAmount + $shippingCost,
            'shipping_cost' => $shippingCost,
            'shipping_address' => $request->shipping_address,
            'phone' => $request->phone,
            'status' => 'pending',
            'payment_status' => 'unpaid'
        ]);
        
        // Create order items
        foreach ($cart->items as $cartItem) {
            OrderItem::create([
                'order_id' => $order->id,
                'product_id' => $cartItem->product->id,
                'product_name' => $cartItem->product->name,
                'price' => $cartItem->product->price,
                'quantity' => $cartItem->quantity
            ]);
        }
        
        // Create Stripe payment intent
        $paymentIntent = $this->stripeService->createPaymentIntent($order);
        
        // Check if payment intent creation was successful and contains client_secret
        if (!$paymentIntent['success'] || !isset($paymentIntent['client_secret'])) {
            return response()->json([
                'status' => false,
                'message' => 'Failed to create payment: ' . ($paymentIntent['message'] ?? 'Unknown error')
            ], 500);
        }
        
        // Clear cart after order creation
        CartItem::where('cart_id', $cart->id)->delete();
        
        return response()->json([
            'status' => true,
            'message' => 'Order created successfully',
            'order' => $order,
            'payment' => [
                'client_secret' => $paymentIntent['client_secret'],
                'publishable_key' => config('services.stripe.key')
            ]
        ]);
    }
    
    /**
     * Get order history (admin only)
     */
    public function allOrders(Request $request)
    {
        // Filter by status if provided
        $status = $request->query('status');
        
        $ordersQuery = Order::with(['items', 'payment', 'user'])
                      ->orderBy('created_at', 'desc');
        
        // Apply status filter if provided
        if ($status && $status !== 'all') {
            $ordersQuery->where('status', $status);
        }
        
        $orders = $ordersQuery->get();
                 
        return response()->json([
            'status' => true,
            'orders' => $orders
        ]);
    }

    public function adminShowOrder($id)
    {
        $order = Order::with(['user', 'items'])->find($id);
        
        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }
        
        return response()->json([
            'order' => $order,
            'success' => true
        ]);
    }
    
    /**
     * Update order status (admin only)
     */
    public function updateStatus(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,processing,shipped,delivered,cancelled'
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid status',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $order = Order::find($id);
        
        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }
        
        $order->status = $request->status;
        $order->save();
        
        return response()->json([
            'success' => true,
            'message' => 'Order status updated successfully',
            'order' => $order
        ]);
    }
    
    /**
     * Update order status and payment status (user only)
     */
    public function updateUserOrderStatus(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,processing,shipped,delivered,cancelled',
            'payment_status' => 'required|in:unpaid,paid,failed,cancelled',
            'transaction_id' => 'nullable|string'
        ]);
        
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid status parameters',
                'errors' => $validator->errors()
            ], 422);
        }
        
        $user = Auth::user();
        $order = Order::where('id', $id)
                ->where('user_id', $user->id)
                ->first();
                
        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found'
            ], 404);
        }
        
        // Update order status
        $order->status = $request->status;
        $order->payment_status = $request->payment_status;
        
        // Update transaction ID if provided
        if ($request->transaction_id) {
            $order->transaction_id = $request->transaction_id;
        }
        
        $order->save();
        
        // Create payment record if status is 'paid'
        if ($request->payment_status === 'paid' && $request->transaction_id) {
            Payment::updateOrCreate(
                ['order_id' => $order->id],
                [
                    'transaction_id' => $request->transaction_id,
                    'amount' => $order->total_amount,
                    'currency' => 'USD',
                    'payment_method' => 'stripe',
                    'status' => 'success',
                ]
            );
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Order status updated successfully',
            'order' => $order
        ]);
    }
}