<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;

class WebAuthController extends Controller
{
    /**
     * Show the login form
     */
    public function showLoginForm()
    {
        // If already logged in, redirect to dashboard
        if (Session::has('auth_token')) {
            return redirect('/admins');
        }
        
        return view('auth.login');
    }
    
    /**
     * Store JWT token in session
     */
    public function storeToken(Request $request)
    {
        $token = $request->input('token');
        
        if ($token) {
            Session::put('auth_token', $token);
            return response()->json(['status' => true]);
        }
        
        return response()->json(['status' => false]);
    }
    
    /**
     * Logout user
     */
    public function logout()
    {
        Session::forget('auth_token');
        return redirect()->route('admin.login');
    }
}