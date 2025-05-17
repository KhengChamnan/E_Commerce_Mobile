<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Mazer Admin Dashboard</title>
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@300;400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="{{ asset('assets/css/bootstrap.css') }}">
    <link rel="stylesheet" href="{{ asset('assets/vendors/bootstrap-icons/bootstrap-icons.css') }}">
    <link rel="stylesheet" href="{{ asset('assets/css/app.css') }}">
    <link rel="stylesheet" href="{{ asset('assets/css/pages/auth.css') }}">
</head>

<body>
    <div id="auth">
        <div class="row h-100">
            <div class="col-lg-5 col-12">
                <div id="auth-left">
                    <div class="auth-logo">
                        <a href="{{ url('/') }}"><img src="{{ asset('assets/images/logo/logo.png') }}" alt="Logo"></a>
                    </div>
                    <h1 class="auth-title">Log in.</h1>
                    <p class="auth-subtitle mb-5">Log in with your data that you entered during registration.</p>

                    <form id="loginForm">
                        <div class="form-group position-relative has-icon-left mb-4">
                            <input type="email" id="email" class="form-control form-control-xl" placeholder="Email">
                            <div class="form-control-icon">
                                <i class="bi bi-envelope"></i>
                            </div>
                            <div class="invalid-feedback" id="emailError"></div>
                        </div>
                        <div class="form-group position-relative has-icon-left mb-4">
                            <input type="password" id="password" class="form-control form-control-xl" placeholder="Password">
                            <div class="form-control-icon">
                                <i class="bi bi-shield-lock"></i>
                            </div>
                            <div class="invalid-feedback" id="passwordError"></div>
                        </div>
                        
                        <button type="button" id="loginBtn" class="btn btn-primary btn-block btn-lg shadow-lg mt-5">Log in</button>
                    </form>

                    <div class="alert alert-danger mt-3" id="loginError" style="display: none;"></div>
                </div>
            </div>
            <div class="col-lg-7 d-none d-lg-block">
                <div id="auth-right">
                </div>
            </div>
        </div>
    </div>

    // Replace your existing script with this one
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const loginBtn = document.getElementById('loginBtn');
        const loginForm = document.getElementById('loginForm');
        const loginError = document.getElementById('loginError');

        // Add event listener to login button
        loginBtn.addEventListener('click', function() {
            // Hide any previous error messages
            loginError.style.display = 'none';
            
            // Reset validation errors
            document.querySelectorAll('.is-invalid').forEach(el => {
                el.classList.remove('is-invalid');
            });
            document.querySelectorAll('.invalid-feedback').forEach(el => {
                el.textContent = '';
            });

            // Get form data
            const email = document.getElementById('email').value;
            const password = document.getElementById('password').value;
            
            // Create request payload
            const data = {
                email: email,
                password: password
            };
            
            // Send login request to API
            fetch('/api/auth/login', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Accept': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(data => {
                if (data.access_token) {
                    // Store token in localStorage
                    localStorage.setItem('auth_token', data.access_token);
                    
                    // Store user data
                    localStorage.setItem('user', JSON.stringify(data.user));
                    
                    // Check if user is admin
                    if (data.user && data.user.role === 'admin') {
                        // Store token in session AND redirect
                        fetch('/store-token', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                            },
                            body: JSON.stringify({ token: data.access_token })
                        })
                        .then(() => {
                            window.location.href = '/admins';
                        });
                    } else {
                        // Not an admin
                        loginError.textContent = 'You do not have permission to access the admin panel';
                        loginError.style.display = 'block';
                    }
                } else {
                    // Show error message
                    loginError.textContent = data.error || 'Login failed. Please check your credentials.';
                    loginError.style.display = 'block';
                }
            })
            .catch(error => {
                console.error('Login error:', error);
                loginError.textContent = 'An error occurred during login. Please try again.';
                loginError.style.display = 'block';
            });
        });

        // Allow form submission with Enter key
        loginForm.addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                loginBtn.click();
            }
        });
    });
</script>
</body>

</html>