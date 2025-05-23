# E-Commerce App (Laravel + Flutter)

This is a full-stack e-commerce application with a Laravel backend API and Flutter mobile frontend.

## Project Structure

- `backend/` - Laravel REST API with JWT authentication
- `frontend/` - Flutter mobile application

## Backend Setup (Laravel)

### Prerequisites

- PHP 8.2 or higher
- Composer
- MySQL
- Node.js and npm (for frontend assets)

### Installation Steps

1. Navigate to the backend directory:
   ```
   cd backend
   ```

2. Install PHP dependencies:
   ```
   composer install
   ```

3. Create and setup environment file:
   ```
   cp .env.example .env
   ```

4. Generate application key:
   ```
   php artisan key:generate
   ```

5. Generate JWT secret:
   ```
   php artisan jwt:secret
   ```

6. Configure the `.env` file with your database credentials:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=laravel_flutter
   DB_USERNAME=root
   DB_PASSWORD=your_password
   ```

7. Run migrations and seed the database:
   ```
   php artisan migrate --seed
   ```

8. Create symbolic link for storage:
   ```
   php artisan storage:link
   ```

9. Start the development server:
   ```
   php artisan serve
   ```

### Useful Artisan Commands

- Clearing cache:
  ```
  php artisan config:clear
  php artisan cache:clear
  php artisan route:clear
  php artisan view:clear
  ```

- Create new controller:
  ```
  php artisan make:controller YourControllerName
  ```

- Create new model with migration:
  ```
  php artisan make:model YourModelName -m
  ```

- Create new middleware:
  ```
  php artisan make:middleware YourMiddlewareName
  ```

- JWT token refresh:
  ```
  php artisan jwt:refresh
  ```

## Frontend Setup (Flutter)

### Prerequisites

- Flutter SDK (3.7.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android SDK for Android development
- Xcode for iOS development (Mac only)

### Installation Steps

1. Navigate to the frontend directory:
   ```
   cd frontend
   ```

2. Install Flutter dependencies:
   ```
   flutter pub get
   ```

3. Update the API base URL in your configuration file to match your Laravel backend URL.

4. Run the Flutter application:
   ```
   flutter run
   ```

### Building for Production

- Android APK:
  ```
  flutter build apk
  ```

- Android App Bundle:
  ```
  flutter build appbundle
  ```

- iOS (Mac only):
  ```
  flutter build ios
  ```

## Stripe Payment Integration

This application uses Stripe for payments. To enable Stripe:

1. Update your backend `.env` file with your Stripe credentials:
   ```
   STRIPE_KEY=your_publishable_key
   STRIPE_SECRET=your_secret_key
   STRIPE_WEBHOOK_SECRET=your_webhook_secret
   ```

2. Make sure the Stripe package is correctly initialized in your Flutter app.

## JWT Authentication

The backend uses JWT (JSON Web Token) for authentication. Token configuration can be modified in `config/jwt.php` or in the `.env` file.

## Additional Information

- Backend API documentation can be accessed at your-backend-url/api/documentation (if Swagger is configured)
- Default admin login: admin@example.com / password (after seeding)
