<!DOCTYPE html>
<html lang="en">

@include('includes.head')

<body>

<!-- sidebar -->
    @include('includes.sidebar')

    <!-- Sidebar end -->

    <div class="page-heading">
        <h3>Orders</h3>
    </div>
    
    <section class="section">
        <div class="row" id="basic-table">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between">
                        <h4 class="card-title">Order Management</h4>
                        <div>
                            <select id="statusFilter" class="form-select">
                                <option value="all">All Orders</option>
                                <option value="pending">Pending</option>
                                <option value="processing">Processing</option>
                                <option value="shipped">Shipped</option>
                                <option value="delivered">Delivered</option>
                                <option value="cancelled">Cancelled</option>
                            </select>
                        </div>
                    </div>
                    <div class="card-content">
                        <div class="card-body">
                            <p class="card-text">All customer orders are listed below. You can view details and update the status of each order.</p>
                            <!-- Table with outer spacing -->
                            <div class="table-responsive">
                                <table class="table table-lg" id="ordersTable">
                                    <thead>
                                        <tr>
                                            <th>ORDER #</th>
                                            <th>CUSTOMER</th>
                                            <th>DATE</th>
                                            <th>TOTAL</th>
                                            <th>STATUS</th>
                                            <th>PAYMENT</th>
                                            <th>ACTIONS</th>
                                        </tr>
                                    </thead>
                                    <tbody id="ordersList">
                                        <!-- Orders will be loaded here dynamically -->
                                        <tr>
                                            <td colspan="7" class="text-center">Loading orders...</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- View Order Details Modal -->
    <div class="modal fade" id="viewOrderModal" tabindex="-1" aria-labelledby="viewOrderModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="viewOrderModalLabel">Order Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <h6>Order Information</h6>
                            <p>
                                <strong>Order Number:</strong> <span id="viewOrderNumber"></span><br>
                                <strong>Date:</strong> <span id="viewOrderDate"></span><br>
                                <strong>Status:</strong> <span id="viewOrderStatus"></span><br>
                                <strong>Payment Status:</strong> <span id="viewPaymentStatus"></span><br>
                                <strong>Transaction ID:</strong> <span id="viewTransactionId"></span>
                            </p>
                        </div>
                        <div class="col-md-6">
                            <h6>Customer Information</h6>
                            <p>
                                <strong>Name:</strong> <span id="viewCustomerName"></span><br>
                                <strong>Phone:</strong> <span id="viewCustomerPhone"></span><br>
                                <strong>Shipping Address:</strong> <span id="viewShippingAddress"></span>
                            </p>
                        </div>
                    </div>
                    
                    <h6>Order Items</h6>
                    <div class="table-responsive">
                        <table class="table" id="orderItemsTable">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Price</th>
                                    <th>Quantity</th>
                                    <th class="text-end">Subtotal</th>
                                </tr>
                            </thead>
                            <tbody id="orderItemsList">
                                <!-- Order items will be loaded here dynamically -->
                            </tbody>
                            <tfoot>
                                <tr>
                                    <td colspan="3" class="text-end"><strong>Subtotal:</strong></td>
                                    <td class="text-end" id="viewSubtotal"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="text-end"><strong>Shipping:</strong></td>
                                    <td class="text-end" id="viewShipping"></td>
                                </tr>
                                <tr>
                                    <td colspan="3" class="text-end"><strong>Total:</strong></td>
                                    <td class="text-end" id="viewTotal"></td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <div class="me-auto">
                        <select id="updateOrderStatus" class="form-select">
                            <option value="pending">Pending</option>
                            <option value="processing">Processing</option>
                            <option value="shipped">Shipped</option>
                            <option value="delivered">Delivered</option>
                            <option value="cancelled">Cancelled</option>
                        </select>
                    </div>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary" id="updateStatusBtn">Update Status</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast Notification -->
    <div class="toast-container position-fixed top-0 end-0 p-3">
        <div id="notificationToast" class="toast" role="alert" aria-live="assertive" aria-atomic="true">
            <div class="toast-header">
                <strong class="me-auto" id="toastTitle">Notification</strong>
                <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
            <div class="toast-body" id="toastMessage"></div>
        </div>
    </div>

    @include('includes.footer')
    
    @include('includes.scripts')

    @include('components.orders-management')
</body>

</html>