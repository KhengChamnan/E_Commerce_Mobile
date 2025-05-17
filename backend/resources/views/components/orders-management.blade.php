<script>
    let currentOrderId;
    
    // Initialize toast
    const toastEl = document.getElementById('notificationToast');
    const toast = new bootstrap.Toast(toastEl);
    
    // Get auth token from localStorage (more reliable than meta tag)
    const authToken = localStorage.getItem('auth_token') || document.querySelector('meta[name="auth-token"]').getAttribute('content');
    
    // Show notification
    function showNotification(title, message, type = 'success') {
        document.getElementById('toastTitle').textContent = title;
        document.getElementById('toastMessage').textContent = message;
        
        toastEl.classList.remove('bg-success', 'bg-danger');
        if (type === 'success') {
            toastEl.classList.add('bg-success', 'text-white');
        } else {
            toastEl.classList.add('bg-danger', 'text-white');
        }
        
        toast.show();
    }

    // Load all orders
    function loadOrders(status = 'all') {
        // Always get the latest token
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        let url = '/api/admin/orders';
        if (status !== 'all') {
            url += `?status=${status}`;
        }
        
        fetch(url, {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            const ordersList = document.getElementById('ordersList');
            ordersList.innerHTML = '';
            
            if (!data.orders || data.orders.length === 0) {
                ordersList.innerHTML = `<tr><td colspan="7" class="text-center">No orders found</td></tr>`;
                return;
            }
            
            data.orders.forEach(order => {
                // Format date
                const orderDate = new Date(order.created_at);
                const formattedDate = orderDate.toLocaleDateString('en-GB', {
                    day: '2-digit',
                    month: 'short',
                    year: 'numeric'
                });
                
                // Status badge
                let statusBadge;
                switch(order.status) {
                    case 'pending':
                        statusBadge = '<span class="badge bg-warning">Pending</span>';
                        break;
                    case 'processing':
                        statusBadge = '<span class="badge bg-info">Processing</span>';
                        break;
                    case 'shipped':
                        statusBadge = '<span class="badge bg-primary">Shipped</span>';
                        break;
                    case 'delivered':
                        statusBadge = '<span class="badge bg-success">Delivered</span>';
                        break;
                    case 'cancelled':
                        statusBadge = '<span class="badge bg-danger">Cancelled</span>';
                        break;
                    default:
                        statusBadge = '<span class="badge bg-secondary">Unknown</span>';
                }
                
                // Payment status badge
                let paymentBadge;
                switch(order.payment_status) {
                    case 'paid':
                        paymentBadge = '<span class="badge bg-success">Paid</span>';
                        break;
                    case 'pending':
                        paymentBadge = '<span class="badge bg-warning">Pending</span>';
                        break;
                    case 'failed':
                        paymentBadge = '<span class="badge bg-danger">Failed</span>';
                        break;
                    default:
                        paymentBadge = '<span class="badge bg-secondary">Unknown</span>';
                }
                
                ordersList.innerHTML += `
                    <tr>
                        <td>${order.order_number}</td>
                        <td>${order.user ? order.user.name : 'N/A'}</td>
                        <td>${formattedDate}</td>
                        <td>$${order.total_amount}</td>
                        <td>${statusBadge}</td>
                        <td>${paymentBadge}</td>
                        <td>
                            <button class="btn btn-sm btn-primary" onclick="viewOrderDetails(${order.id})">
                                <i class="bi bi-eye"></i> View
                            </button>
                        </td>
                    </tr>
                `;
            });
        })
        .catch(error => {
            console.error('Error loading orders:', error);
            showNotification('Error', 'Failed to load orders', 'error');
        });
    }

    // View order details
    function viewOrderDetails(orderId) {
        currentOrderId = orderId;
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/admin/orders/${orderId}`, {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (!data.order) {
                showNotification('Error', 'Order not found', 'error');
                return;
            }
            
            const order = data.order;
            
            // Fill order information
            document.getElementById('viewOrderNumber').textContent = order.order_number;
            
            const orderDate = new Date(order.created_at);
            document.getElementById('viewOrderDate').textContent = orderDate.toLocaleDateString('en-GB', {
                day: '2-digit',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
            });
            
            document.getElementById('viewOrderStatus').textContent = order.status.charAt(0).toUpperCase() + order.status.slice(1);
            document.getElementById('viewPaymentStatus').textContent = order.payment_status.charAt(0).toUpperCase() + order.payment_status.slice(1);
            document.getElementById('viewTransactionId').textContent = order.transaction_id || 'N/A';
            
            // Customer information
            document.getElementById('viewCustomerName').textContent = order.user ? order.user.name : 'N/A';
            document.getElementById('viewCustomerPhone').textContent = order.phone || 'N/A';
            document.getElementById('viewShippingAddress').textContent = order.shipping_address || 'N/A';
            
            // Order items
            const orderItemsList = document.getElementById('orderItemsList');
            orderItemsList.innerHTML = '';
            
            let subtotal = 0;
            
            order.items.forEach(item => {
                const itemSubtotal = item.price * item.quantity;
                subtotal += itemSubtotal;
                
                orderItemsList.innerHTML += `
                    <tr>
                        <td>${item.product_name}</td>
                        <td>$${parseFloat(item.price).toFixed(2)}</td>
                        <td>${item.quantity}</td>
                        <td class="text-end">$${parseFloat(itemSubtotal).toFixed(2)}</td>
                    </tr>
                `;
            });
            
            // Order totals
            document.getElementById('viewSubtotal').textContent = `$${parseFloat(subtotal).toFixed(2)}`;
            document.getElementById('viewShipping').textContent = `$${parseFloat(order.shipping_cost).toFixed(2)}`;
            document.getElementById('viewTotal').textContent = `$${parseFloat(order.total_amount).toFixed(2)}`;
            
            // Set current status in the dropdown
            const statusDropdown = document.getElementById('updateOrderStatus');
            statusDropdown.value = order.status;
            
            // Open the modal
            const viewOrderModal = new bootstrap.Modal(document.getElementById('viewOrderModal'));
            viewOrderModal.show();
        })
        .catch(error => {
            console.error('Error loading order details:', error);
            showNotification('Error', 'Failed to load order details', 'error');
        });
    }

    // Update order status
    document.getElementById('updateStatusBtn').addEventListener('click', function() {
        const newStatus = document.getElementById('updateOrderStatus').value;
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/admin/orders/${currentOrderId}/status`, {
            method: 'PATCH',
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify({
                status: newStatus
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                showNotification('Success', 'Order status updated successfully');
                
                // Close the modal
                const viewOrderModal = bootstrap.Modal.getInstance(document.getElementById('viewOrderModal'));
                viewOrderModal.hide();
                
                // Reload orders
                loadOrders(document.getElementById('statusFilter').value);
            } else {
                showNotification('Error', data.message || 'Failed to update order status', 'error');
            }
        })
        .catch(error => {
            console.error('Error updating order status:', error);
            showNotification('Error', 'Failed to update order status', 'error');
        });
    });

    // Status filter
    document.getElementById('statusFilter').addEventListener('change', function() {
        loadOrders(this.value);
    });

    // Initialize page
    document.addEventListener('DOMContentLoaded', function() {
        loadOrders();
    });
</script>