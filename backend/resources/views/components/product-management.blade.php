<script>
    let currentProductId;
    
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

    // Load all products
    function loadProducts() {
        // Always get the latest token
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch('/api/products', {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status) {
                const productsList = document.getElementById('productsList');
                productsList.innerHTML = '';
                
                if (data.products.length === 0) {
                    productsList.innerHTML = `<tr><td colspan="7" class="text-center">No products found</td></tr>`;
                    return;
                }
                
                data.products.forEach(product => {
                    let imageHtml = product.image 
                        ? `<img src="/storage/products/${product.image}" alt="${product.name}" width="50">` 
                        : '<span class="badge bg-light text-dark">No image</span>';
                        
                    productsList.innerHTML += `
                        <tr data-id="${product.id}">
                            <td class="text-bold-500">${product.name}</td>
                            <td>$${parseFloat(product.price).toFixed(2)}</td>
                            <td>${product.category ? product.category.name : 'N/A'}</td>
                            <td>${product.brand ? product.brand.name : 'N/A'}</td>
                            <td>${imageHtml}</td>
                            <td>
                                <button class="btn btn-sm btn-primary view-product-btn" data-id="${product.id}">
                                    <i class="bi bi-eye"></i>
                                </button>
                                <button class="btn btn-sm btn-primary edit-product-btn" data-id="${product.id}">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button class="btn btn-sm btn-danger delete-product-btn" data-id="${product.id}">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    `;
                });
                
                // Add event listeners to buttons
                document.querySelectorAll('.view-product-btn').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        const productId = e.currentTarget.getAttribute('data-id');
                        openViewModal(productId);
                    });
                });
                
                document.querySelectorAll('.edit-product-btn').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        const productId = e.currentTarget.getAttribute('data-id');
                        openEditModal(productId);
                    });
                });
                
                document.querySelectorAll('.delete-product-btn').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        const productId = e.currentTarget.getAttribute('data-id');
                        openDeleteModal(productId);
                    });
                });
            }
        })
        .catch(error => {
            console.error('Error loading products:', error);
            showNotification('Error', 'Failed to load products', 'error');
        });
    }
    
    // Load categories for dropdown
    function loadCategories(selectElementId, selectedCategoryId = null) {
        const currentToken = localStorage.getItem('auth_token') || authToken;
        const selectElement = document.getElementById(selectElementId);
        
        fetch('/api/categories', {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status && data.categories.length > 0) {
                selectElement.innerHTML = '<option value="">Select Category</option>';
                
                data.categories.forEach(category => {
                    const selected = selectedCategoryId && category.id == selectedCategoryId ? 'selected' : '';
                    selectElement.innerHTML += `<option value="${category.id}" ${selected}>${category.name}</option>`;
                });
            }
        })
        .catch(error => {
            console.error('Error loading categories:', error);
        });
    }
    
    // Load brands for dropdown
    function loadBrands(selectElementId, selectedBrandId = null) {
        const currentToken = localStorage.getItem('auth_token') || authToken;
        const selectElement = document.getElementById(selectElementId);
        
        fetch('/api/brands', {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status && data.brands.length > 0) {
                selectElement.innerHTML = '<option value="">Select Brand (Optional)</option>';
                
                data.brands.forEach(brand => {
                    const selected = selectedBrandId && brand.id == selectedBrandId ? 'selected' : '';
                    selectElement.innerHTML += `<option value="${brand.id}" ${selected}>${brand.name}</option>`;
                });
            }
        })
        .catch(error => {
            console.error('Error loading brands:', error);
        });
    }

    // Create new product
    document.getElementById('saveProductBtn').addEventListener('click', () => {
        const form = document.getElementById('addProductForm');
        const formData = new FormData(form);
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        // Reset error messages
        document.querySelectorAll('.invalid-feedback').forEach(el => {
            el.textContent = '';
        });
        document.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });
        
        fetch('/api/products', {
            method: 'POST',
            body: formData,
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Authorization': 'Bearer ' + currentToken
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status) {
                // Close modal and show success message
                bootstrap.Modal.getInstance(document.getElementById('addProductModal')).hide();
                form.reset();
                showNotification('Success', 'Product created successfully');
                loadProducts();
            } else {
                // Display validation errors
                if (data.errors) {
                    Object.keys(data.errors).forEach(field => {
                        const errorEl = document.getElementById(`${field}Error`);
                        const inputEl = document.getElementById(`product${field.charAt(0).toUpperCase() + field.slice(1)}`);
                        if (errorEl && inputEl) {
                            errorEl.textContent = data.errors[field][0];
                            inputEl.classList.add('is-invalid');
                        }
                    });
                }
                showNotification('Error', data.message || 'Failed to create product', 'error');
            }
        })
        .catch(error => {
            console.error('Error creating product:', error);
            showNotification('Error', 'Failed to create product', 'error');
        });
    });
    
    // Open view modal
    function openViewModal(productId) {
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/products/${productId}`, {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status) {
                const product = data.product;
                document.getElementById('viewProductName').textContent = product.name;
                document.getElementById('viewProductDescription').textContent = product.description || 'No description';
                document.getElementById('viewProductPrice').textContent = `$${parseFloat(product.price).toFixed(2)}`;
                document.getElementById('viewProductCategory').textContent = product.category ? product.category.name : 'N/A';
                document.getElementById('viewProductBrand').textContent = product.brand ? product.brand.name : 'N/A';
                
                // Show product image if exists
                const productImageEl = document.getElementById('viewProductImage');
                if (product.image) {
                    productImageEl.innerHTML = `
                        <img src="/storage/products/${product.image}" alt="${product.name}" class="img-fluid">
                    `;
                } else {
                    productImageEl.innerHTML = '<p>No image available</p>';
                }
                
                // Open modal
                const viewModal = new bootstrap.Modal(document.getElementById('viewProductModal'));
                viewModal.show();
            } else {
                showNotification('Error', 'Failed to load product details', 'error');
            }
        })
        .catch(error => {
            console.error('Error loading product details:', error);
            showNotification('Error', 'Failed to load product details', 'error');
        });
    }

    // Open edit modal
    function openEditModal(productId) {
        currentProductId = productId;
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/products/${productId}`, {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status) {
                const product = data.product;
                document.getElementById('editProductId').value = product.id;
                document.getElementById('editProductName').value = product.name;
                document.getElementById('editProductDescription').value = product.description || '';
                document.getElementById('editProductPrice').value = product.price;
                
                // Load categories and brands dropdowns
                loadCategories('editProductCategory', product.category_id);
                loadBrands('editProductBrand', product.brand_id);
                
                // Show current image if exists
                const currentImageEl = document.getElementById('currentImage');
                if (product.image) {
                    currentImageEl.innerHTML = `
                        <p>Current image:</p>
                        <img src="/storage/products/${product.image}" alt="${product.name}" width="100">
                    `;
                } else {
                    currentImageEl.innerHTML = '<p>No image uploaded</p>';
                }
                
                // Open modal
                const editModal = new bootstrap.Modal(document.getElementById('editProductModal'));
                editModal.show();
            } else {
                showNotification('Error', 'Failed to load product details', 'error');
            }
        })
        .catch(error => {
            console.error('Error loading product details:', error);
            showNotification('Error', 'Failed to load product details', 'error');
        });
    }

    // Update product
    // Update product
    document.getElementById('updateProductBtn').addEventListener('click', () => {
        const form = document.getElementById('editProductForm');
        const formData = new FormData(form);
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        // Add _method field for Laravel to recognize it as PUT request
        formData.append('_method', 'PUT');
        
        fetch(`/api/products/${currentProductId}`, {
            method: 'POST', // Use POST with _method field
            body: formData,
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Authorization': 'Bearer ' + currentToken
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status) {
                // Close modal and show success message
                bootstrap.Modal.getInstance(document.getElementById('editProductModal')).hide();
                form.reset();
                showNotification('Success', 'Product updated successfully');
                loadProducts();
            } else {
                // Display validation errors if any
                if (data.errors) {
                    Object.keys(data.errors).forEach(field => {
                        const errorEl = document.getElementById(`edit${field.charAt(0).toUpperCase() + field.slice(1)}Error`);
                        const inputEl = document.getElementById(`editProduct${field.charAt(0).toUpperCase() + field.slice(1)}`);
                        if (errorEl && inputEl) {
                            errorEl.textContent = data.errors[field][0];
                            inputEl.classList.add('is-invalid');
                        }
                    });
                }
                showNotification('Error', data.message || 'Failed to update product', 'error');
            }
        })
        .catch(error => {
            console.error('Error updating product:', error);
            showNotification('Error', 'Failed to update product', 'error');
        });
    });

    // Open delete modal
    function openDeleteModal(productId) {
        currentProductId = productId;
        const deleteModal = new bootstrap.Modal(document.getElementById('deleteProductModal'));
        deleteModal.show();
    }

    // Delete product
    // Delete product
        document.getElementById('confirmDeleteBtn').addEventListener('click', () => {
            const currentToken = localStorage.getItem('auth_token') || authToken;
            
            // Use FormData with _method field for proper method spoofing
            const formData = new FormData();
            formData.append('_method', 'DELETE');
            
            fetch(`/api/products/${currentProductId}`, {
                method: 'POST', // Use POST with _method field
                body: formData,
                headers: {
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                    'Authorization': 'Bearer ' + currentToken
                }
            })
            .then(response => response.json())
            .then(data => {
                // Close modal
                bootstrap.Modal.getInstance(document.getElementById('deleteProductModal')).hide();
                
                if (data.status) {
                    showNotification('Success', 'Product deleted successfully');
                    loadProducts();
                } else {
                    showNotification('Error', data.message || 'Failed to delete product', 'error');
                }
            })
            .catch(error => {
                console.error('Error deleting product:', error);
                showNotification('Error', 'Failed to delete product', 'error');
                bootstrap.Modal.getInstance(document.getElementById('deleteProductModal')).hide();
            });
        });
    
    // Initialize page
    document.addEventListener('DOMContentLoaded', function() {
        // Update token meta tag if token exists in localStorage
        const storedToken = localStorage.getItem('auth_token');
        if (storedToken) {
            const tokenMeta = document.querySelector('meta[name="auth-token"]');
            if (tokenMeta) {
                tokenMeta.setAttribute('content', storedToken);
            }
        }
        
        // Load initial data
        loadProducts();
        
        // Load categories and brands for add product form
        loadCategories('productCategory');
        loadBrands('productBrand');
        
        // Add event listener for "Add Product" button click
        document.getElementById('addProductModalBtn').addEventListener('click', () => {
            // Reset form fields
            document.getElementById('addProductForm').reset();
            // Reset validation errors
            document.querySelectorAll('.invalid-feedback').forEach(el => {
                el.textContent = '';
            });
            document.querySelectorAll('.is-invalid').forEach(el => {
                el.classList.remove('is-invalid');
            });
        });
    });
</script>