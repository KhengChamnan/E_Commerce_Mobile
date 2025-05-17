document.addEventListener('DOMContentLoaded', function() {
    // Get token from localStorage
    const token = localStorage.getItem('auth_token');
    
    // Update meta tag if token exists
    if (token) {
        const metaTag = document.querySelector('meta[name="auth-token"]');
        if (metaTag) {
            metaTag.setAttribute('content', token);
        }
    }
});