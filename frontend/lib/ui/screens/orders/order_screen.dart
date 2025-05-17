import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/ui/providers/order_provider.dart';
import 'package:frontend/models/order.dart';
import 'widgets/order_item_card.dart';
import 'widgets/order_tab_indicator.dart';
import 'widgets/empty_order_message.dart';
import 'order_detail_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use refreshOrders instead of getOrders to ensure all data is fresh
      await Provider.of<OrderProvider>(context, listen: false).refreshOrders();
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "My Orders",
          style: TextStyle(
            fontFamily: 'Quicksand',
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black.withOpacity(0.5),
                labelStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                indicator: OrderTabIndicator(
                  color: Colors.black,
                  height: 3,
                ),
                tabs: const [
                  Tab(text: "Active"),
                  Tab(text: "Completed"),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Consumer<OrderProvider>(
                      builder: (context, orderProvider, child) {
                        final ordersState = orderProvider.orders;

                        if (ordersState.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (ordersState.hasError) {
                          return Center(
                            child: Text(
                              'Error: ${orderProvider.lastErrorMessage ?? "Failed to load orders"}',
                              style: const TextStyle(
                                fontFamily: 'Quicksand',
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        if (!ordersState.hasData || ordersState.data!.isEmpty) {
                          return const EmptyOrderMessage();
                        }

                        // Filter orders based on active tab
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            // Active orders tab
                            _buildOrdersList(
                              ordersState.data!.where((order) => 
                                order.status != 'delivered' && 
                                order.status != 'cancelled').toList()
                            ),
                            
                            // Completed orders tab
                            _buildOrdersList(
                              ordersState.data!.where((order) => 
                                order.status == 'delivered' || 
                                order.status == 'cancelled').toList()
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return const EmptyOrderMessage();
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: OrderItemCard(
              order: order,
              onTap: () async {
                // Navigate to order details page and refresh data when returning
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(order: order),
                  ),
                );
                // Refresh orders when returning to ensure we have the latest data
                if (mounted) {
                  _loadOrders();
                }
              },
            ),
          );
        },
      ),
    );
  }
} 