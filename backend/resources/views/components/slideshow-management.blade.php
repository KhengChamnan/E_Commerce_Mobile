<script>
    let currentSlideshowId;
    
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

    // Load all slideshows
    function loadSlideshows() {
        // Always get the latest token
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch('/api/slideshows', {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status) {
                const slideshowsList = document.getElementById('slideshowsList');
                slideshowsList.innerHTML = '';
                
                if (!data.slideshows || data.slideshows.length === 0) {
                    slideshowsList.innerHTML = `<tr><td colspan="9" class="text-center">No slideshow items found</td></tr>`;
                    return;
                }
                
                data.slideshows.forEach(slideshow => {
                    let imageHtml = slideshow.image 
                        ? `<img src="/storage/slideshows/${slideshow.image}" alt="${slideshow.name}" width="80">` 
                        : '<span class="badge bg-light text-dark">No image</span>';
                        
                    let statusBadge = slideshow.enable 
                        ? '<span class="badge bg-success">Active</span>' 
                        : '<span class="badge bg-secondary">Inactive</span>';
                        
                    let linkDisplay = slideshow.link 
                        ? `<a href="${slideshow.link}" target="_blank" class="badge bg-info text-white">View Link</a>`
                        : '<span class="badge bg-light text-dark">No Custom Link</span>';
                        
                    slideshowsList.innerHTML += `
                        <tr data-id="${slideshow.id}">
                            <td>${imageHtml}</td>
                            <td class="text-bold-500">${slideshow.name}</td>
                            <td>${slideshow.description ? (slideshow.description.length > 30 ? slideshow.description.substring(0, 30) + '...' : slideshow.description) : 'N/A'}</td>
                            <td>$${parseFloat(slideshow.price).toFixed(2)}</td>
                            <td>${slideshow.product ? slideshow.product.name : 'N/A'}</td>
                            <td>${statusBadge}</td>
                            <td>${slideshow.ssorder}</td>
                            <td>${linkDisplay}</td>
                            <td>
                                <button class="btn btn-sm btn-primary edit-slideshow-btn" data-id="${slideshow.id}">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button class="btn btn-sm btn-danger delete-slideshow-btn" data-id="${slideshow.id}">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    `;
                });
                
                // Add event listeners to buttons
                document.querySelectorAll('.edit-slideshow-btn').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        const slideshowId = e.currentTarget.getAttribute('data-id');
                        openEditModal(slideshowId);
                    });
                });
                
                document.querySelectorAll('.delete-slideshow-btn').forEach(btn => {
                    btn.addEventListener('click', (e) => {
                        const slideshowId = e.currentTarget.getAttribute('data-id');
                        openDeleteModal(slideshowId);
                    });
                });
            }
        })
        .catch(error => {
            console.error('Error loading slideshows:', error);
            showNotification('Error', 'Failed to load slideshows', 'error');
        });
    }
    
    // Load products for dropdown
    function loadProducts(selectElementId, selectedProductId = null) {
        const currentToken = localStorage.getItem('auth_token') || authToken;
        const selectElement = document.getElementById(selectElementId);
        
        fetch('/api/products', {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status && data.products && data.products.length > 0) {
                selectElement.innerHTML = '<option value="">Select Product</option>';
                
                data.products.forEach(product => {
                    const selected = selectedProductId && product.id == selectedProductId ? 'selected' : '';
                    selectElement.innerHTML += `<option value="${product.id}" ${selected}>${product.name}</option>`;
                });
            } else {
                selectElement.innerHTML = '<option value="">No products available</option>';
            }
        })
        .catch(error => {
            console.error('Error loading products:', error);
            selectElement.innerHTML = '<option value="">Error loading products</option>';
        });
    }

    // Create new slideshow
    document.getElementById('saveSlideshowBtn').addEventListener('click', () => {
        const form = document.getElementById('addSlideshowForm');
        const formData = new FormData(form);
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        // Handle checkbox for enable
        if (!formData.has('enable')) {
            formData.append('enable', '0');
        }
        
        // Reset error messages
        document.querySelectorAll('.invalid-feedback').forEach(el => {
            el.textContent = '';
        });
        document.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });
        
        fetch('/api/slideshows', {
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
                bootstrap.Modal.getInstance(document.getElementById('addSlideshowModal')).hide();
                form.reset();
                showNotification('Success', 'Slideshow created successfully');
                loadSlideshows();
            } else {
                // Display validation errors
                if (data.errors) {
                    Object.keys(data.errors).forEach(field => {
                        const errorEl = document.getElementById(`${field}Error`);
                        const inputEl = document.getElementById(`slideshow${field.charAt(0).toUpperCase() + field.slice(1)}`);
                        if (errorEl && inputEl) {
                            errorEl.textContent = data.errors[field][0];
                            inputEl.classList.add('is-invalid');
                        }
                    });
                }
                showNotification('Error', data.message || 'Failed to create slideshow', 'error');
            }
        })
        .catch(error => {
            console.error('Error creating slideshow:', error);
            showNotification('Error', 'Failed to create slideshow', 'error');
        });
    });

    // Open edit modal
    function openEditModal(slideshowId) {
        currentSlideshowId = slideshowId;
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/slideshows/${slideshowId}`, {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status) {
                const slideshow = data.slideshow;
                document.getElementById('editSlideshowId').value = slideshow.id;
                document.getElementById('editSlideshowName').value = slideshow.name;
                document.getElementById('editSlideshowDescription').value = slideshow.description || '';
                document.getElementById('editSlideshowPrice').value = slideshow.price;
                document.getElementById('editSlideshowLink').value = slideshow.link || '';
                document.getElementById('editSlideshowOrder').value = slideshow.ssorder || 0;
                document.getElementById('editSlideshowEnable').checked = slideshow.enable;
                
                // Load products dropdown
                loadProducts('editSlideshowProduct', slideshow.product_id);
                
                // Show current image if exists
                const currentImageEl = document.getElementById('currentImage');
                if (slideshow.image) {
                    currentImageEl.innerHTML = `
                        <p>Current image:</p>
                        <img src="/storage/slideshows/${slideshow.image}" alt="${slideshow.name}" class="img-fluid" style="max-height: 200px;">
                    `;
                } else {
                    currentImageEl.innerHTML = '<p>No image uploaded</p>';
                }
                
                // Open modal
                const editModal = new bootstrap.Modal(document.getElementById('editSlideshowModal'));
                editModal.show();
            } else {
                showNotification('Error', 'Failed to load slideshow details', 'error');
            }
        })
        .catch(error => {
            console.error('Error loading slideshow details:', error);
            showNotification('Error', 'Failed to load slideshow details', 'error');
        });
    }

    // Update slideshow
    document.getElementById('updateSlideshowBtn').addEventListener('click', () => {
        const form = document.getElementById('editSlideshowForm');
        const formData = new FormData(form);
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        // Handle checkbox for enable
        if (!formData.has('enable')) {
            formData.append('enable', '0');
        }
        
        // Reset error messages
        document.querySelectorAll('.invalid-feedback').forEach(el => {
            el.textContent = '';
        });
        document.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });
        
        fetch(`/api/slideshows/${currentSlideshowId}`, {
            method: 'POST',
            body: formData,
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'X-HTTP-Method-Override': 'PUT',
                'Authorization': 'Bearer ' + currentToken
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.status) {
                // Close modal and show success message
                bootstrap.Modal.getInstance(document.getElementById('editSlideshowModal')).hide();
                form.reset();
                showNotification('Success', 'Slideshow updated successfully');
                loadSlideshows();
            } else {
                // Display validation errors
                if (data.errors) {
                    Object.keys(data.errors).forEach(field => {
                        const errorEl = document.getElementById(`edit${field.charAt(0).toUpperCase() + field.slice(1)}Error`);
                        const inputEl = document.getElementById(`editSlideshow${field.charAt(0).toUpperCase() + field.slice(1)}`);
                        if (errorEl && inputEl) {
                            errorEl.textContent = data.errors[field][0];
                            inputEl.classList.add('is-invalid');
                        }
                    });
                }
                showNotification('Error', data.message || 'Failed to update slideshow', 'error');
            }
        })
        .catch(error => {
            console.error('Error updating slideshow:', error);
            showNotification('Error', 'Failed to update slideshow', 'error');
        });
    });

    // Open delete modal
    function openDeleteModal(slideshowId) {
        currentSlideshowId = slideshowId;
        const deleteModal = new bootstrap.Modal(document.getElementById('deleteSlideshowModal'));
        deleteModal.show();
    }

    // Delete slideshow
    document.getElementById('confirmDeleteBtn').addEventListener('click', () => {
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/slideshows/${currentSlideshowId}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Authorization': 'Bearer ' + currentToken
            }
        })
        .then(response => response.json())
        .then(data => {
            // Close modal
            bootstrap.Modal.getInstance(document.getElementById('deleteSlideshowModal')).hide();
            
            if (data.status) {
                showNotification('Success', 'Slideshow deleted successfully');
                loadSlideshows();
            } else {
                showNotification('Error', data.message || 'Failed to delete slideshow', 'error');
            }
        })
        .catch(error => {
            console.error('Error deleting slideshow:', error);
            showNotification('Error', 'Failed to delete slideshow', 'error');
            bootstrap.Modal.getInstance(document.getElementById('deleteSlideshowModal')).hide();
        });
    });

    // Initialize page
    document.addEventListener('DOMContentLoaded', function() {
        // Load slideshows
        loadSlideshows();
        
        // Load products for add slideshow form
        loadProducts('slideshowProduct');
        
        // Update token meta tag if token exists in localStorage
        const storedToken = localStorage.getItem('auth_token');
        if (storedToken) {
            const tokenMeta = document.querySelector('meta[name="auth-token"]');
            if (tokenMeta) {
                tokenMeta.setAttribute('content', storedToken);
            }
        }
        
        // Add event listener for "Add Slideshow" button click
        document.getElementById('addSlideshowModalBtn').addEventListener('click', () => {
            // Reset form fields
            document.getElementById('addSlideshowForm').reset();
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