<!DOCTYPE html>
<html lang="en">

@include('includes.head')

<body>

<!-- sidebar -->
    @include('includes.sidebar')

    <!-- Sidebar end -->

    <div class="page-heading">
        <h3>Brands</h3>
    </div>
    
    <section class="section">
        <div class="row" id="basic-table">
            <div class="col-12">
                <div class="card">
                    <div class="card-header d-flex justify-content-between">
                        <h4 class="card-title">Brand Management</h4>
                        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addBrandModal">
                            <i class="bi bi-plus"></i> Add Brand
                        </button>
                    </div>
                    <div class="card-content">
                        <div class="card-body">
                            <p class="card-text">All brands are listed below. You can add, edit or delete brands.</p>
                            <!-- Table with outer spacing -->
                            <div class="table-responsive">
                                <table class="table table-lg" id="brandsTable">
                                    <thead>
                                        <tr>
                                            <th>NAME</th>
                                            <th>DESCRIPTION</th>
                                            <th>LOGO</th>
                                            <th>ACTIONS</th>
                                        </tr>
                                    </thead>
                                    <tbody id="brandsList">
                                        <!-- Brands will be loaded here dynamically -->
                                        <tr>
                                            <td colspan="4" class="text-center">Loading brands...</td>
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

    <!-- Add Brand Modal -->
    <div class="modal fade" id="addBrandModal" tabindex="-1" aria-labelledby="addBrandModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="addBrandModalLabel">Add New Brand</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="addBrandForm" enctype="multipart/form-data">
                        <div class="mb-3">
                            <label for="brandName" class="form-label">Brand Name</label>
                            <input type="text" class="form-control" id="brandName" name="name" required>
                            <div class="invalid-feedback" id="nameError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="brandDescription" class="form-label">Description</label>
                            <textarea class="form-control" id="brandDescription" name="description" rows="3"></textarea>
                            <div class="invalid-feedback" id="descriptionError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="brandLogo" class="form-label">Logo</label>
                            <input type="file" class="form-control" id="brandLogo" name="logo" accept="image/*">
                            <div class="invalid-feedback" id="logoError"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="saveBrandBtn">Save Brand</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Brand Modal -->
    <div class="modal fade" id="editBrandModal" tabindex="-1" aria-labelledby="editBrandModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="editBrandModalLabel">Edit Brand</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="editBrandForm" enctype="multipart/form-data">
                        <input type="hidden" id="editBrandId">
                        <div class="mb-3">
                            <label for="editBrandName" class="form-label">Brand Name</label>
                            <input type="text" class="form-control" id="editBrandName" name="name" required>
                            <div class="invalid-feedback" id="editNameError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="editBrandDescription" class="form-label">Description</label>
                            <textarea class="form-control" id="editBrandDescription" name="description" rows="3"></textarea>
                            <div class="invalid-feedback" id="editDescriptionError"></div>
                        </div>
                        <div class="mb-3">
                            <label for="editBrandLogo" class="form-label">Logo</label>
                            <div id="currentLogo" class="mb-2"></div>
                            <input type="file" class="form-control" id="editBrandLogo" name="logo" accept="image/*">
                            <div class="invalid-feedback" id="editLogoError"></div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-primary" id="updateBrandBtn">Update Brand</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Delete Confirmation Modal -->
    <div class="modal fade" id="deleteBrandModal" tabindex="-1" aria-labelledby="deleteBrandModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="deleteBrandModalLabel">Confirm Delete</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <p>Are you sure you want to delete this brand?</p>
                    <p class="text-danger">This action cannot be undone.</p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete Brand</button>
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

    @include('components.brand-management')
</body>

</html>