<div id="app">
        <div id="sidebar" class="active">
            <div class="sidebar-wrapper active">
                <div class="sidebar-header">
                    <div class="d-flex justify-content-between">
                        <div class="logo">
                            <a href="{{ url('/') }}"><img src="{{ asset('assets/images/logo/logo.png') }}" alt="Logo" srcset=""></a>
                        </div>
                        <div class="toggler">
                            <a href="#" class="sidebar-hide d-xl-none d-block"><i class="bi bi-x bi-middle"></i></a>
                        </div>
                    </div>
                </div>
                <div class="sidebar-menu">
                    <ul class="menu">
                        <li class="sidebar-title">Menu</li>

                        <li class="sidebar-item {{ request()->is('admins') ? 'active' : '' }}">
                            <a href="{{ url('admins') }}" class='sidebar-link'>
                                <i class="bi bi-grid-fill"></i>
                                <span>Dashboard</span>
                            </a>
                        </li>

                        <li class="sidebar-item has-sub {{ request()->is('products*') || request()->is('brands*') || request()->is('categories*') || request()->is('slideshows*') ? 'active' : '' }}">
                            <a href="#" class='sidebar-link'>
                                <i class="bi bi-box"></i>
                                <span>Catalog</span>
                            </a>
                            <ul class="submenu {{ request()->is('products*') || request()->is('brands*') || request()->is('categories*') || request()->is('slideshows*') ? 'active' : '' }}">
                                <li class="submenu-item {{ request()->is('products*') ? 'active' : '' }}">
                                    <a href="{{ url('products') }}">Products</a>
                                </li>
                                <li class="submenu-item {{ request()->is('brands*') ? 'active' : '' }}">
                                    <a href="{{ url('brands') }}">Brands</a>
                                </li>
                                <li class="submenu-item {{ request()->is('categories*') ? 'active' : '' }}">
                                    <a href="{{ url('categories') }}">Category</a>
                                </li>
                                <li class="submenu-item {{ request()->is('slideshows*') ? 'active' : '' }}">
                                    <a href="{{ url('slideshows') }}">Slideshow</a>
                                    
                                </li>
                            </ul>
                        <!-- After the Catalog menu item, add a standalone Orders item -->
                        <li class="sidebar-item {{ request()->is('orders*') ? 'active' : '' }}">
                            <a href="{{ url('orders') }}" class='sidebar-link'>
                                <i class="bi bi-cart"></i>
                                <span>Orders</span>
                            </a>
                        </li>
                        <li class="sidebar-item">
                        <a href="{{ url('logout') }}" class='sidebar-link'>
                            <i class="bi bi-box-arrow-right"></i>
                            <span>Logout</span>
                        </a>
                        </li>
                    </li>

                        
                <button class="sidebar-toggler btn x"><i data-feather="x"></i></button>
            </div>
        </div>
        <div id="main">
            <header class="mb-3">
                <a href="#" class="burger-btn d-block d-xl-none">
                    <i class="bi bi-justify fs-3"></i>
                </a>
            </header>