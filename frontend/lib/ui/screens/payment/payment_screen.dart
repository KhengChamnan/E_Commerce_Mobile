import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;
import 'package:frontend/models/order.dart';
import 'package:frontend/ui/providers/cart_provider.dart';
import 'package:frontend/ui/providers/payment_provider.dart';
import 'package:frontend/ui/providers/order_provider.dart';
import 'package:provider/provider.dart';

class PaymentScreen extends StatefulWidget {
  final Order order;

  const PaymentScreen({Key? key, required this.order}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Reset payment state when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().resetPaymentState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Detail',
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Order summary card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order #: ${widget.order.orderNumber}',
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '\$${widget.order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF21D69F),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Payment options heading
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Stripe payment option
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.network(
                        'https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Stripe_Logo%2C_revised_2016.svg/2560px-Stripe_Logo%2C_revised_2016.svg.png',
                        height: 30,
                        width: 70,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Pay with credit/debit card',
                          style: TextStyle(
                            fontFamily: 'Quicksand',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Radio(
                        value: true, 
                        groupValue: true,
                        onChanged: (value) {},
                        activeColor: const Color(0xFF21D69F),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Display payment status
              Consumer<PaymentProvider>(
                builder: (context, provider, child) {
                  final paymentState = provider.paymentState;
                  
                  if (paymentState.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF21D69F),
                      ),
                    );
                  }
                  
                  if (paymentState.hasError) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Error: ${paymentState.error}',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          color: Colors.red.shade800,
                        ),
                      ),
                    );
                  }
                  
                  if (paymentState.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      final data = paymentState.data!;
                      // Show Stripe payment sheet
                      if (data['success'] == true && data['clientSecret'] != null) {
                        try {
                          print('Initializing payment sheet with client secret: ${data['clientSecret']}');
                          // Initialize the payment sheet
                          await stripe.Stripe.instance.initPaymentSheet(
                            paymentSheetParameters: stripe.SetupPaymentSheetParameters(
                              merchantDisplayName: 'Your Store',
                              customerId: null,
                              paymentIntentClientSecret: data['clientSecret'],
                              style: ThemeMode.light,
                            ),
                          );
                          
                          print('Presenting payment sheet');
                          // Present the payment sheet
                          await stripe.Stripe.instance.presentPaymentSheet();
                          
                          print('Payment successful');
                          // If no exception, payment succeeded
                          // Clear the cart after successful payment
                          context.read<CartProvider>().clearCart();
                          
                          // Update order status on the backend
                          final String? paymentIntentId = data['payment_intent_id'];
                          
                          await context.read<OrderProvider>().updateOrderStatus(
                            orderId: widget.order.id,
                            status: 'processing', // Change status from pending to processing
                            paymentStatus: 'paid', // Change payment status to paid
                            transactionId: paymentIntentId,
                          );
                          
                          // Show success dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                'Payment Successful',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: const Text(
                                'Your payment was processed successfully. Your order will be delivered soon!',
                                style: TextStyle(
                                  fontFamily: 'Quicksand',
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    // Reset payment state and navigate back to home
                                    provider.resetPaymentState();
                                    Navigator.popUntil(context, (route) => route.isFirst);
                                  },
                                  child: const Text(
                                    'OK',
                                    style: TextStyle(
                                      fontFamily: 'Quicksand',
                                      color: Color(0xFF21D69F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } catch (e) {
                          print('Payment error: $e');
                          // Payment failed or was canceled
                          context.read<PaymentProvider>().resetPaymentState();
                        }
                      }
                    });
                  }
                  
                  return const SizedBox.shrink();
                },
              ),
              
              // Payment button
              ElevatedButton(
                onPressed: _isProcessing 
                    ? null 
                    : () => _processPayment(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF21D69F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      )
                    : const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Process the payment with Stripe
  Future<void> _processPayment(BuildContext context) async {
    setState(() {
      _isProcessing = true;
    });
    
    try {
      print('Processing payment for order: ${widget.order.id}');
      await context.read<PaymentProvider>().makePayment(
        orderId: widget.order.id,
      );
      
      // Get the payment state after making the payment
      final paymentState = context.read<PaymentProvider>().paymentState;
      
      if (paymentState.hasError) {
        return;
      }
      
      if (paymentState.hasData && paymentState.data!['success'] == true) {
        try {
          // Initialize the payment sheet
          await stripe.Stripe.instance.initPaymentSheet(
            paymentSheetParameters: stripe.SetupPaymentSheetParameters(
              merchantDisplayName: 'Your Store',
              customerId: null,
              paymentIntentClientSecret: paymentState.data!['clientSecret'],
              style: ThemeMode.light,
            ),
          );
          
          // Present the payment sheet
          await stripe.Stripe.instance.presentPaymentSheet();
          
          // If no exception, payment succeeded
          // Clear the cart after successful payment
          context.read<CartProvider>().clearCart();
          
          // Update order status on the backend
          final String? paymentIntentId = paymentState.data!['payment_intent_id'];
          
          await context.read<OrderProvider>().updateOrderStatus(
            orderId: widget.order.id,
            status: 'processing', // Change status from pending to processing
            paymentStatus: 'paid', // Change payment status to paid
            transactionId: paymentIntentId,
          );
          
          // Show success dialog
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text(
                'Payment Successful',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: const Text(
                'Your payment was processed successfully. Your order will be delivered soon!',
                style: TextStyle(
                  fontFamily: 'Quicksand',
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // Reset payment state and navigate back to home
                    context.read<PaymentProvider>().resetPaymentState();
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      color: Color(0xFF21D69F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        } catch (e) {
          print('Payment error: $e');
          // Payment failed or was canceled
          context.read<PaymentProvider>().resetPaymentState();
        }
      } else {
        if (!mounted) return;
      }
    } catch (e) {
      print('Payment processing error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
}