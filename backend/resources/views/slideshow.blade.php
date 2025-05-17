<!DOCTYPE html>
<html lang="en">

@include('includes.head')

<body>

<!-- sidebar -->
    @include('includes.sidebar')

    <!-- Sidebar end -->

    <div class="page-heading">
        <h3>Slideshows</h3>
    </div>
    
    <section class="section">
        <div class="row" id="basic-table">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between">
                        <h4 class="card-title">Slideshow Management</h4>
                        <button class="btn btn-primary" id="addSlideshowModalBtn" data-bs-toggle="modal" data-bs-target="#addSlideshowModal">
                            <i class="bi bi-plus"></i> Add Slideshow
                        </button>
                    </div>
                    <div class="card-content">
                        <div class="card-body">
                            <p class="card-text">All slideshow items are listed below. You can add, edit or delete slideshows.</p>
                            <!-- Table with outer spacing -->
                            <div class="table-responsive">
                                <table class="table table-lg" id="slideshowsTable">
                                    <thead>
                                        <tr>
                                            <th>IMAGE</th>
                                            <th>NAME</th>
                                            <th>DESCRIPTION</th>
                                            <th>PRICE</th>
                                            <th>PRODUCT</th>
                                            <th>STATUS</th>
                                            <th>ORDER</th>
                                            <th>LINK</th>
                                            <th>ACTIONS</th>
                                        </tr>
                                    </thead>
                                    <tbody id="slideshowsList">
                                        <!-- Slideshows will be loaded here dynamically -->
                                        <tr>
                                            <td colspan="9" class="text-center">Loading slideshows...</td>
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

    <!-- Add Slideshow Modal -->
    <div class="modal fade" id="addSlideshowModal" tabindex="-1" aria-labelledby="addSlideshowModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addSlideshowModalLabel">Add New Slideshow</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="addSlideshowForm" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label for="slideshowName" class="form-label">Name</label>
                            <input type="text" class="form-control" id="slideshowName" name="name" required>
                            <div class="invalid-feedback" id="nameError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="slideshowDescription" class="form-label">Description</label>
                            <textarea class="form-control" id="slideshowDescription" name="description" rows="3" required></textarea>
                            <div class="invalid-feedback" id="descriptionError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="slideshowPrice" class="form-label">Price</label>
                            <input type="number" step="0.01" class="form-control" id="slideshowPrice" name="price" required>
                            <div class="invalid-feedback" id="priceError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="slideshowProduct" class="form-label">Product</label>
                            <select class="form-select" id="slideshowProduct" name="product_id" required>
                                <option value="">Loading products...</option>
                            </select>
                            <div class="invalid-feedback" id="product_idError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="slideshowLink" class="form-label">Custom Link (Optional)</label>
                            <input type="url" class="form-control" id="slideshowLink" name="link" placeholder="https://example.com/product">
                            <div class="invalid-feedback" id="linkError"></div>
                            <small class="form-text text-muted">Enter a custom link to the product or leave blank to use default product page.</small>
                        </div>
                        <div class="mb-3">
                            <label for="slideshowOrder" class="form-label">Display Order</label>
                            <input type="number" class="form-control" id="slideshowOrder" name="ssorder" value="0" min="0">
                            <div class="invalid-feedback" id="ssorderError"></div>
                            <small class="form-text text-muted">Lower numbers appear first. Items with the same order value are sorted by date.</small>
                        </div>
                        <div class="mb-3">
                            <label for="slideshowImage" class="form-label">Slideshow Image</label>
                            <input type="file" class="form-control" id="slideshowImage" name="image" accept="image/*">
                            <div class="invalid-feedback" id="imageError"></div>
                        </div>
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="slideshowEnable" name="enable" value="1" checked>
                            <label class="form-check-label" for="slideshowEnable">Enable Slideshow</label>
                            <div class="invalid-feedback" id="enableError"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveSlideshowBtn">Save Slideshow</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Slideshow Modal -->
    <div class="modal fade" id="editSlideshowModal" tabindex="-1" aria-labelledby="editSlideshowModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editSlideshowModalLabel">Edit Slideshow</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editSlideshowForm" enctype="multipart/form-data">
                        <input type="hidden" id="editSlideshowId" name="id">
                        <div class="mb-3">
                            <label for="editSlideshowName" class="form-label">Name</label>
                            <input type="text" class="form-control" id="editSlideshowName" name="name" required>
                            <div class="invalid-feedback" id="editNameError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="editSlideshowDescription" class="form-label">Description</label>
                            <textarea class="form-control" id="editSlideshowDescription" name="description" rows="3" required></textarea>
                            <div class="invalid-feedback" id="editDescriptionError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="editSlideshowPrice" class="form-label">Price</label>
                            <input type="number" step="0.01" class="form-control" id="editSlideshowPrice" name="price" required>
                            <div class="invalid-feedback" id="editPriceError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="editSlideshowProduct" class="form-label">Product</label>
                            <select class="form-select" id="editSlideshowProduct" name="product_id" required>
                                <option value="">Loading products...</option>
                            </select>
                            <div class="invalid-feedback" id="editProduct_idError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="editSlideshowLink" class="form-label">Custom Link (Optional)</label>
                            <input type="url" class="form-control" id="editSlideshowLink" name="link" placeholder="https://example.com/product">
                            <div class="invalid-feedback" id="editLinkError"></div>
                            <small class="form-text text-muted">Enter a custom link to the product or leave blank to use default product page.</small>
                        </div>
                        <div class="mb-3">
                            <label for="editSlideshowOrder" class="form-label">Display Order</label>
                            <input type="number" class="form-control" id="editSlideshowOrder" name="ssorder" value="0" min="0">
                            <div class="invalid-feedback" id="editSsorderError"></div>
                            <small class="form-text text-muted">Lower numbers appear first. Items with the same order value are sorted by date.</small>
                        </div>
                        <div class="mb-3">
                            <label for="editSlideshowImage" class="form-label">Slideshow Image</label>
                            <div id="currentImage" class="mb-2"></div>
                            <input type="file" class="form-control" id="editSlideshowImage" name="image" accept="image/*">
                            <div class="invalid-feedback" id="editImageError"></div>
                        </div>
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="editSlideshowEnable" name="enable" value="1">
                            <label class="form-check-label" for="editSlideshowEnable">Enable Slideshow</label>
                            <div class="invalid-feedback" id="editEnableError"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="updateSlideshowBtn">Update Slideshow</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteSlideshowModal" tabindex="-1" aria-labelledby="deleteSlideshowModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteSlideshowModalLabel">Confirm Delete</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this slideshow?</p>
                    <p class="text-danger">This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete Slideshow</button>
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

    @include('components.slideshow-management')
</body>

</html>