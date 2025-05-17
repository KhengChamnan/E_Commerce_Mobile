document.addEventListener('DOMContentLoaded', function() {
    // Update auth token meta tag from localStorage if available
    const storedToken = localStorage.getItem('auth_token');
    if (storedToken) {
        const tokenMeta = document.getElementById('auth-token-meta');
        if (tokenMeta) {
            tokenMeta.setAttribute('content', storedToken);
        }
    }
    
    // Set up automatic token refresh
    setupTokenRefresh();
});

function setupTokenRefresh() {
    // Check token every minute
    setInterval(function() {
        const token = localStorage.getItem('auth_token');
        if (!token) return;
        
        // Parse the token to check expiration (JWT tokens are base64 encoded)
        try {
            const payload = JSON.parse(atob(token.split('.')[1]));
            const expiryTime = payload.exp * 1000; // Convert to milliseconds
            const currentTime = Date.now();
            
            // If token will expire in the next 5 minutes, refresh it
            if ((expiryTime - currentTime) < 300000) {
                refreshToken();
            }
        } catch (e) {
            console.error('Error checking token expiration:', e);
        }
    }, 60000); // Check every minute
}

function refreshToken() {
    const currentToken = localStorage.getItem('auth_token');
    if (!currentToken) return;
    
    fetch('/api/auth/refresh', {
        method: 'POST',
        headers: {
            'Authorization': 'Bearer ' + currentToken,
            'Accept': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.access_token) {
            // Update token in localStorage
            localStorage.setItem('auth_token', data.access_token);
            
            // Update meta tag
            const tokenMeta = document.getElementById('auth-token-meta');
            if (tokenMeta) {
                tokenMeta.setAttribute('content', data.access_token);
            }
            
            // Update token in session
            fetch('/store-token', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                },
                body: JSON.stringify({ token: data.access_token })
            });
        }
    })
    .catch(error => {
        console.error('Token refresh failed:', error);
    });
}