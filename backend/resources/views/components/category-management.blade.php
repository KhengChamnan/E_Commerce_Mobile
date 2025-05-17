<script>
    let currentCategoryId;
    
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

    // Load all categories
    function loadCategories() {
        // Always get the latest token
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch('/api/categories', {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
            .then(response => response.json())
            .then(data => {
                if (data.status) {
                    const categoriesList = document.getElementById('categoriesList');
                    categoriesList.innerHTML = '';
                    
                    if (data.categories.length === 0) {
                        categoriesList.innerHTML = `<tr><td colspan="3" class="text-center">No categories found</td></tr>`;
                        return;
                    }
                    
                    data.categories.forEach(category => {
                        categoriesList.innerHTML += `
                            <tr data-id="${category.id}">
                                <td class="text-bold-500">${category.name}</td>
                                <td>${category.description || 'N/A'}</td>
                                <td>
                                    <button class="btn btn-sm btn-primary edit-category-btn" data-id="${category.id}">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <button class="btn btn-sm btn-danger delete-category-btn" data-id="${category.id}">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </td>
                            </tr>
                        `;
                    });
                    
                    // Add event listeners to buttons
                    document.querySelectorAll('.edit-category-btn').forEach(btn => {
                        btn.addEventListener('click', (e) => {
                            const categoryId = e.currentTarget.getAttribute('data-id');
                            openEditModal(categoryId);
                        });
                    });
                    
                    document.querySelectorAll('.delete-category-btn').forEach(btn => {
                        btn.addEventListener('click', (e) => {
                            const categoryId = e.currentTarget.getAttribute('data-id');
                            openDeleteModal(categoryId);
                        });
                    });
                }
            })
            .catch(error => {
                console.error('Error loading categories:', error);
                showNotification('Error', 'Failed to load categories', 'error');
            });
    }

    // Create new category
    document.getElementById('saveCategoryBtn').addEventListener('click', () => {
        const form = document.getElementById('addCategoryForm');
        const formData = new FormData(form);
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        // Reset error messages
        document.querySelectorAll('.invalid-feedback').forEach(el => {
            el.textContent = '';
        });
        document.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });
        
        fetch('/api/categories', {
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
                bootstrap.Modal.getInstance(document.getElementById('addCategoryModal')).hide();
                form.reset();
                showNotification('Success', 'Category created successfully');
                loadCategories();
            } else {
                // Display validation errors
                if (data.errors) {
                    Object.keys(data.errors).forEach(field => {
                        const errorEl = document.getElementById(`${field}Error`);
                        const inputEl = document.getElementById(`category${field.charAt(0).toUpperCase() + field.slice(1)}`);
                        if (errorEl && inputEl) {
                            errorEl.textContent = data.errors[field][0];
                            inputEl.classList.add('is-invalid');
                        }
                    });
                }
                showNotification('Error', data.message || 'Failed to create category', 'error');
            }
        })
        .catch(error => {
            console.error('Error creating category:', error);
            showNotification('Error', 'Failed to create category', 'error');
        });
    });

    // Open edit modal
    function openEditModal(categoryId) {
        currentCategoryId = categoryId;
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/categories/${categoryId}`, {
            headers: {
                'Authorization': 'Bearer ' + currentToken,
                'Accept': 'application/json'
            }
        })
            .then(response => response.json())
            .then(data => {
                if (data.status) {
                    const category = data.category;
                    document.getElementById('editCategoryId').value = category.id;
                    document.getElementById('editCategoryName').value = category.name;
                    document.getElementById('editCategoryDescription').value = category.description || '';
                    
                    // Open modal
                    const editModal = new bootstrap.Modal(document.getElementById('editCategoryModal'));
                    editModal.show();
                } else {
                    showNotification('Error', 'Failed to load category details', 'error');
                }
            })
            .catch(error => {
                console.error('Error loading category details:', error);
                showNotification('Error', 'Failed to load category details', 'error');
            });
    }

    // Update category
    document.getElementById('updateCategoryBtn').addEventListener('click', () => {
        const form = document.getElementById('editCategoryForm');
        const formData = new FormData(form);
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        // Reset error messages
        document.querySelectorAll('.invalid-feedback').forEach(el => {
            el.textContent = '';
        });
        document.querySelectorAll('.is-invalid').forEach(el => {
            el.classList.remove('is-invalid');
        });
        
        fetch(`/api/categories/${currentCategoryId}`, {
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
                bootstrap.Modal.getInstance(document.getElementById('editCategoryModal')).hide();
                form.reset();
                showNotification('Success', 'Category updated successfully');
                loadCategories();
            } else {
                // Display validation errors
                if (data.errors) {
                    Object.keys(data.errors).forEach(field => {
                        const errorEl = document.getElementById(`edit${field.charAt(0).toUpperCase() + field.slice(1)}Error`);
                        const inputEl = document.getElementById(`editCategory${field.charAt(0).toUpperCase() + field.slice(1)}`);
                        if (errorEl && inputEl) {
                            errorEl.textContent = data.errors[field][0];
                            inputEl.classList.add('is-invalid');
                        }
                    });
                }
                showNotification('Error', data.message || 'Failed to update category', 'error');
            }
        })
        .catch(error => {
            console.error('Error updating category:', error);
            showNotification('Error', 'Failed to update category', 'error');
        });
    });

    // Open delete modal
    function openDeleteModal(categoryId) {
        currentCategoryId = categoryId;
        const deleteModal = new bootstrap.Modal(document.getElementById('deleteCategoryModal'));
        deleteModal.show();
    }

    // Delete category
    document.getElementById('confirmDeleteBtn').addEventListener('click', () => {
        const currentToken = localStorage.getItem('auth_token') || authToken;
        
        fetch(`/api/categories/${currentCategoryId}`, {
            method: 'DELETE',
            headers: {
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
                'Authorization': 'Bearer ' + currentToken
            }
        })
        .then(response => response.json())
        .then(data => {
            // Close modal
            bootstrap.Modal.getInstance(document.getElementById('deleteCategoryModal')).hide();
            
            if (data.status) {
                showNotification('Success', 'Category deleted successfully');
                loadCategories();
            } else {
                showNotification('Error', data.message || 'Failed to delete category', 'error');
            }
        })
        .catch(error => {
            console.error('Error deleting category:', error);
            showNotification('Error', 'Failed to delete category', 'error');
            bootstrap.Modal.getInstance(document.getElementById('deleteCategoryModal')).hide();
        });
    });

    // Load categories when page loads
    document.addEventListener('DOMContentLoaded', loadCategories);
</script>