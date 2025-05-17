<!DOCTYPE html>
<html lang="en">

@include('includes.head')

<body>

<!-- sidebar -->
    @include('includes.sidebar')

    <!-- Sidebar end -->

    <div class="page-heading">
        <h3>Products</h3>
    </div>
    
    <section class="section">
        <div class="row" id="basic-table">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between">
                        <h4 class="card-title">Product Management</h4>
                        <button class="btn btn-primary" id="addProductModalBtn" data-bs-toggle="modal" data-bs-target="#addProductModal">
                            <i class="bi bi-plus"></i> Add Product
                        </button>
                    </div>
                    <div class="card-content">
                        <div class="card-body">
                            <p class="card-text">All products are listed below. You can add, view, edit or delete products.</p>
                            <!-- Table with outer spacing -->
                            <div class="table-responsive">
                                <table class="table table-lg" id="productsTable">
                                    <thead>
                                        <tr>
                                            <th>NAME</th>
                                            <th>PRICE</th>
                                            <th>CATEGORY</th>
                                            <th>BRAND</th>
                                            <th>IMAGE</th>
                                            <th>ACTIONS</th>
                                        </tr>
                                    </thead>
                                    <tbody id="productsList">
                                        <!-- Products will be loaded here dynamically -->
                                        <tr>
                                            <td colspan="6" class="text-center">Loading products...</td>
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

    <!-- Add Product Modal -->
    <div class="modal fade" id="addProductModal" tabindex="-1" aria-labelledby="addProductModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addProductModalLabel">Add New Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="addProductForm" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label for="productName" class="form-label">Product Name</label>
                            <input type="text" class="form-control" id="productName" name="name" required>
                            <div class="invalid-feedback" id="nameError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="productDescription" class="form-label">Description</label>
                            <textarea class="form-control" id="productDescription" name="description" rows="3" required></textarea>
                            <div class="invalid-feedback" id="descriptionError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="productPrice" class="form-label">Price</label>
                            <input type="number" step="0.01" class="form-control" id="productPrice" name="price" required>
                            <div class="invalid-feedback" id="priceError"></div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="productCategory" class="form-label">Category</label>
                                <select class="form-select" id="productCategory" name="category_id" required>
                                    <option value="">Loading categories...</option>
                                </select>
                                <div class="invalid-feedback" id="category_idError"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="productBrand" class="form-label">Brand (Optional)</label>
                                <select class="form-select" id="productBrand" name="brand_id">
                                    <option value="">Loading brands...</option>
                                </select>
                                <div class="invalid-feedback" id="brand_idError"></div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="productImage" class="form-label">Product Image</label>
                            <input type="file" class="form-control" id="productImage" name="image" accept="image/*">
                            <div class="invalid-feedback" id="imageError"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveProductBtn">Save Product</button>
                </div>
            </div>
        </div>
    </div>

    <!-- View Product Modal -->
    <div class="modal fade" id="viewProductModal" tabindex="-1" aria-labelledby="viewProductModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="viewProductModalLabel">Product Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div id="viewProductImage" class="mb-3"></div>
                        </div>
                        <div class="col-md-6">
                            <h4 id="viewProductName"></h4>
                            <p><strong>Price:</strong> <span id="viewProductPrice"></span></p>
                            <p><strong>Category:</strong> <span id="viewProductCategory"></span></p>
                            <p><strong>Brand:</strong> <span id="viewProductBrand"></span></p>
                            <hr>
                            <h5>Description</h5>
                            <p id="viewProductDescription"></p>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Product Modal -->
    <div class="modal fade" id="editProductModal" tabindex="-1" aria-labelledby="editProductModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editProductModalLabel">Edit Product</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editProductForm" enctype="multipart/form-data">
                        <input type="hidden" id="editProductId">
                        <div class="mb-3">
                            <label for="editProductName" class="form-label">Product Name</label>
                            <input type="text" class="form-control" id="editProductName" name="name" required>
                            <div class="invalid-feedback" id="editNameError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="editProductDescription" class="form-label">Description</label>
                            <textarea class="form-control" id="editProductDescription" name="description" rows="3" required></textarea>
                            <div class="invalid-feedback" id="editDescriptionError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="editProductPrice" class="form-label">Price</label>
                            <input type="number" step="0.01" class="form-control" id="editProductPrice" name="price" required>
                            <div class="invalid-feedback" id="editPriceError"></div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="editProductCategory" class="form-label">Category</label>
                                <select class="form-select" id="editProductCategory" name="category_id" required>
                                    <option value="">Loading categories...</option>
                                </select>
                                <div class="invalid-feedback" id="editCategory_idError"></div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label for="editProductBrand" class="form-label">Brand (Optional)</label>
                                <select class="form-select" id="editProductBrand" name="brand_id">
                                    <option value="">Loading brands...</option>
                                </select>
                                <div class="invalid-feedback" id="editBrand_idError"></div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="editProductImage" class="form-label">Product Image</label>
                            <div id="currentImage" class="mb-2"></div>
                            <input type="file" class="form-control" id="editProductImage" name="image" accept="image/*">
                            <div class="invalid-feedback" id="editImageError"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="updateProductBtn">Update Product</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteProductModal" tabindex="-1" aria-labelledby="deleteProductModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteProductModalLabel">Confirm Delete</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this product?</p>
                    <p class="text-danger">This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete Product</button>
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

    @include('components.product-management')
</body>

</html>