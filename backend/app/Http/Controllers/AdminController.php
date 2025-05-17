<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class AdminController extends Controller
{

    public function dashboard()
    {
        return view('dashboard');
    }

    public function products()
    {
        return view('product');
    }

    public function categories()
    {
        return view('category');
    }

    public function brands()
    {
        return view('brand');
    }

    public function slideshows()
    {
        return view('slideshow');
    }

    public function orders()
    {
        return view('orders');
    }
}