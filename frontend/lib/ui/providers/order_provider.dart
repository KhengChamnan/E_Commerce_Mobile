import 'package:flutter/foundation.dart';
import 'package:frontend/data/repository/order_repository.dart';
import 'package:frontend/models/order.dart';
import 'package:frontend/ui/providers/async_value.dart';

class OrderProvider with ChangeNotifier {
  final OrderRepository _repository;
  
  // State for orders list
  AsyncValue<List<Order>> _orders = AsyncValue.empty();
  AsyncValue<List<Order>> get orders => _orders;
  
  // State for current order details
  AsyncValue<Order?> _currentOrder = AsyncValue.empty();
  AsyncValue<Order?> get currentOrder => _currentOrder;
  
  // State for order creation
  bool _isCreatingOrder = false;
  bool get isCreatingOrder => _isCreatingOrder;
  
  // Last operation error message
  String? _lastErrorMessage;
  String? get lastErrorMessage => _lastErrorMessage;
  
  OrderProvider({required OrderRepository repository}) 
    : _repository = repository;
  
  // Fetch all orders for the user
  Future<void> getOrders() async {
    try {
      _orders = AsyncValue.loading();
      notifyListeners();
      
      final orders = await _repository.getOrders();
      _orders = AsyncValue.success(orders);
      _lastErrorMessage = null;
    } catch (e) {
      _orders = AsyncValue.error(e);
      _lastErrorMessage = "Failed to load orders: ${e.toString()}";
    } finally {
      notifyListeners();
    }
  }
  
  // Get a specific order by ID
  Future<void> getOrderById(int orderId) async {
    try {
      _currentOrder = AsyncValue.loading();
      notifyListeners();
      
      final order = await _repository.getOrderById(orderId);
      _currentOrder = AsyncValue.success(order);
      
      // Also update this order in the orders list if present
      if (_orders.hasData) {
        final orderList = List<Order>.from(_orders.data!);
        final index = orderList.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          orderList[index] = order;
          _orders = AsyncValue.success(orderList);
        }
      }
      
      _lastErrorMessage = null;
    } catch (e) {
      _currentOrder = AsyncValue.error(e);
      _lastErrorMessage = "Failed to load order details: ${e.toString()}";
    } finally {
      notifyListeners();
    }
  }
  
  // Create a new order
  Future<Order?> createOrder({
    required String shippingAddress,
    required String phone,
  }) async {
    try {
      _isCreatingOrder = true;
      notifyListeners();
      
      final order = await _repository.createOrder(
        shippingAddress: shippingAddress,
        phone: phone,
      );
      
      _lastErrorMessage = null;
      
      // Add the new order to the orders list if it exists
      if (_orders.hasData) {
        final updatedOrders = [order, ..._orders.data!];
        _orders = AsyncValue.success(updatedOrders);
      }
      
      // Set the new order as current order
      _currentOrder = AsyncValue.success(order);
      
      notifyListeners();
      return order;
    } catch (e) {
      _lastErrorMessage = "Failed to create order: ${e.toString()}";
      notifyListeners();
      return null;
    } finally {
      _isCreatingOrder = false;
      notifyListeners();
    }
  }
  
  // Update order status after payment
  Future<bool> updateOrderStatus({
    required int orderId,
    required String status,
    required String paymentStatus,
    String? transactionId,
  }) async {
    try {
      final updatedOrder = await _repository.updateOrderStatus(
        orderId: orderId,
        status: status,
        paymentStatus: paymentStatus,
        transactionId: transactionId,
      );
      
      // Update current order if it's the same as the updated one
      if (_currentOrder.hasData && _currentOrder.data?.id == orderId) {
        _currentOrder = AsyncValue.success(updatedOrder);
      }
      
      // Update in orders list if present
      if (_orders.hasData) {
        final orderList = List<Order>.from(_orders.data!);
        final index = orderList.indexWhere((order) => order.id == orderId);
        if (index != -1) {
          orderList[index] = updatedOrder;
          _orders = AsyncValue.success(orderList);
        }
      }
      
      _lastErrorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _lastErrorMessage = "Failed to update order status: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }
  
  // Refresh all order data (useful after loading the screen)
  Future<void> refreshOrders() async {
    await getOrders();
    
    // If there's a current order, refresh its data as well
    if (_currentOrder.hasData && _currentOrder.data != null) {
      await getOrderById(_currentOrder.data!.id);
    }
  }
  
  // Reset any error messages
  void clearErrors() {
    _lastErrorMessage = null;
    notifyListeners();
  }
  
  // Clear current order details
  void clearCurrentOrder() {
    _currentOrder = AsyncValue.empty();
    notifyListeners();
  }
}
