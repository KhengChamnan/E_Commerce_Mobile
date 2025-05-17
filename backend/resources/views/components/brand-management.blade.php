<script>
    let currentBrandId;
    
    // Initialize toast
    const toastEl = document.getElementById('notificationToast');
    const toast = new bootstrap.Toast(toastEl);
    
    // Get auth token from localStorage (more reliable than meta tag)
    const authToken = localStorage.getItem('auth_token') || document.querySelector('meta[name="auth-token"]').getAttribute('content');
    
    // Update the meta tag with localStorage token if available
    document.addEventListener('DOMContentLoaded', function() {
        const storedToken = localStorage.getItem('auth_token');
        if (storedToken) {
            const tokenMeta = document.querySelector('meta[name="auth-token"]');
            if (tokenMeta) {
                tokenMeta.setAttribute('content', storedToken);
            }
        }
    });
    
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

    // Load all brands
    function loadBrands() {
        // Always get the latest token
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch('/api/brands', {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
            .then(response => response.json())
            .then(data => {
                if (data.status) {
                    const brandsList = document.getElementById('brandsList');
                    brandsList.innerHTML = '';
                    
                    if (data.brands.length === 0) {
                        brandsList.innerHTML = `<tr><td colspan="4" class="text-center">No brands found</td></tr>`;
                        return;
                    }
                    
                    data.brands.forEach(brand => {
                        // Fix: Changed from /storage/brands/ to /storage/brands/
                        let logoHtml = brand.logo 
                            ? `<img src="/storage/brands/${brand.logo}" alt="${brand.name} logo" width="50">` 
                            : '<span class="badge bg-light text-dark">No logo</span>';
                            
                        brandsList.innerHTML += `
                            <tr data-id="${brand.id}">
                                <td class="text-bold-500">${brand.name}</td>
                                <td>${brand.description || 'N/A'}</td>
                                <td>${logoHtml}</td>
                                <td>
                                    <button class="btn btn-sm btn-primary edit-brand-btn" data-id="${brand.id}">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <button class="btn btn-sm btn-danger delete-brand-btn" data-id="${brand.id}">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        `;
                    });
                    
                    // Add event listeners to buttons
                    document.querySelectorAll('.edit-brand-btn').forEach(btn => {
                        btn.addEventListener('click', (e) => {
                            const brandId = e.currentTarget.getAttribute('data-id');
                            openEditModal(brandId);
                        });
                    });
                    
                    document.querySelectorAll('.delete-brand-btn').forEach(btn => {
                        btn.addEventListener('click', (e) => {
                            const brandId = e.currentTarget.getAttribute('data-id');
                            openDeleteModal(brandId);
                        });
                    });
                }
            })
            .catch(error => {
                console.error('Error loading brands:', error);
                showNotification('Error', 'Failed to load brands', 'error');
            });
    }

    // Create new brand
    document.getElementById('saveBrandBtn').addEventListener('click', () => {
        const form = document.getElementById('addBrandForm');
        const formData = new FormData(form);
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        // Reset error messages
        document.querySelectorAll('.invalid-feedback').forEach(el => {
            el.textContent = '';
        });
        document.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });
        
        fetch('/api/brands', {
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
                bootstrap.Modal.getInstance(document.getElementById('addBrandModal')).hide();
                form.reset();
                showNotification('Success', 'Brand created successfully');
                loadBrands();
            } else {
                // Display validation errors
                if (data.errors) {
                    Object.keys(data.errors).forEach(field => {
                        const errorEl = document.getElementById(`${field}Error`);
                        const inputEl = document.getElementById(`brand${field.charAt(0).toUpperCase() + field.slice(1)}`);
                        if (errorEl && inputEl) {
                            errorEl.textContent = data.errors[field][0];
                            inputEl.classList.add('is-invalid');
                        }
                    });
                }
                showNotification('Error', data.message || 'Failed to create brand', 'error');
            }
        })
        .catch(error => {
            console.error('Error creating brand:', error);
            showNotification('Error', 'Failed to create brand', 'error');
        });
    });

    // Open edit modal
    function openEditModal(brandId) {
        currentBrandId = brandId;
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/brands/${brandId}`, {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
            .then(response => response.json())
            .then(data => {
                if (data.status) {
                    const brand = data.brand;
                    document.getElementById('editBrandId').value = brand.id;
                    document.getElementById('editBrandName').value = brand.name;
                    document.getElementById('editBrandDescription').value = brand.description || '';
                    
                    // Show current logo if exists
                    const currentLogoEl = document.getElementById('currentLogo');
                    if (brand.logo) {
                        // Fix: Changed from /storage/brands/ to /storage/brands/
                        currentLogoEl.innerHTML = `
                            <p>Current logo:</p>
                            <img src="/storage/brands/${brand.logo}" alt="${brand.name} logo" width="100">
                        `;
                    } else {
                        currentLogoEl.innerHTML = '<p>No logo uploaded</p>';
                    }
                    
                    // Open modal
                    const editModal = new bootstrap.Modal(document.getElementById('editBrandModal'));
                    editModal.show();
                } else {
                    showNotification('Error', 'Failed to load brand details', 'error');
                }
            })
            .catch(error => {
                console.error('Error loading brand details:', error);
                showNotification('Error', 'Failed to load brand details', 'error');
            });
    }

    // Update brand
    document.getElementById('updateBrandBtn').addEventListener('click', () => {
        const form = document.getElementById('editBrandForm');
        const formData = new FormData(form);
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        // Reset error messages
        document.querySelectorAll('.invalid-feedback').forEach(el => {
            el.textContent = '';
        });
        document.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });
        
        fetch(`/api/brands/${currentBrandId}`, {
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
                bootstrap.Modal.getInstance(document.getElementById('editBrandModal')).hide();
                form.reset();
                showNotification('Success', 'Brand updated successfully');
                loadBrands();
            } else {
                // Display validation errors
                if (data.errors) {
                    Object.keys(data.errors).forEach(field => {
                        const errorEl = document.getElementById(`edit${field.charAt(0).toUpperCase() + field.slice(1)}Error`);
                        const inputEl = document.getElementById(`editBrand${field.charAt(0).toUpperCase() + field.slice(1)}`);
                        if (errorEl && inputEl) {
                            errorEl.textContent = data.errors[field][0];
                            inputEl.classList.add('is-invalid');
                        }
                    });
                }
                showNotification('Error', data.message || 'Failed to update brand', 'error');
            }
        })
        .catch(error => {
            console.error('Error updating brand:', error);
            showNotification('Error', 'Failed to update brand', 'error');
        });
    });

    // Open delete modal
    function openDeleteModal(brandId) {
        currentBrandId = brandId;
        const deleteModal = new bootstrap.Modal(document.getElementById('deleteBrandModal'));
        deleteModal.show();
    }

    // Delete brand
    document.getElementById('confirmDeleteBtn').addEventListener('click', () => {
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/brands/${currentBrandId}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Authorization': 'Bearer ' + currentToken
            }
        })
        .then(response => response.json())
        .then(data => {
            // Close modal
            bootstrap.Modal.getInstance(document.getElementById('deleteBrandModal')).hide();
            
            if (data.status) {
                showNotification('Success', 'Brand deleted successfully');
                loadBrands();
            } else {
                showNotification('Error', data.message || 'Failed to delete brand', 'error');
            }
        })
        .catch(error => {
            console.error('Error deleting brand:', error);
            showNotification('Error', 'Failed to delete brand', 'error');
            bootstrap.Modal.getInstance(document.getElementById('deleteBrandModal')).hide();
        });
    });

    // Load brands when page loads
    document.addEventListener('DOMContentLoaded', loadBrands);
</script>