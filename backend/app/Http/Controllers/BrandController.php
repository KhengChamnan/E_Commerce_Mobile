<?php

namespace App\Http\Controllers;

use App\Models\Brand;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class BrandController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $brands = Brand::latest()->get();
        
        return response()->json([
            'status' => true,
            'brands' => $brands
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255|unique:brands',
            'description' => 'nullable|string',
            'logo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if($validator->fails()){
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $logoPath = null;
        if ($request->hasFile('logo')) {
            $logo = $request->file('logo');
            $filename = 'brand_' . time() . '.' . $logo->getClientOriginalExtension();
            // Store in public/storage/brands
            Storage::disk('public')->putFileAs('brands', $logo, $filename);
            $logoPath = $filename;
        }

        $brand = Brand::create([
            'name' => $request->name,
            'description' => $request->description,
            'logo' => $logoPath
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Brand created successfully',
            'brand' => $brand
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Brand $brand)
    {
        return response()->json([
            'status' => true,
            'brand' => $brand
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Brand $brand)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255|unique:brands,name,' . $brand->id,
            'description' => 'nullable|string',
            'logo' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        if($validator->fails()){
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->only(['name', 'description']);

        if ($request->hasFile('logo')) {
            // Delete old logo if exists
            if ($brand->logo) {
                Storage::disk('public')->delete($brand->logo);
            }
            
            $logo = $request->file('logo');
            $filename = 'brand_' . time() . '.' . $logo->getClientOriginalExtension();
            Storage::disk('public')->putFileAs('brands', $logo, $filename);
            $data['logo'] = $filename;
        }

        $brand->update($data);

        return response()->json([
            'status' => true,
            'message' => 'Brand updated successfully',
            'brand' => $brand
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Brand $brand)
    {
        // Check if the brand has products
       // Check if the brand has products
       if ($brand->products()->count() > 0) {
        return response()->json([
            'status' => false,
            'message' => 'Cannot delete brand with associated products'
        ], 422);
    }

    // Delete logo if exists
    if ($brand->logo) {
        Storage::disk('public')->delete($brand->logo);
    }

        $brand->delete();

        return response()->json([
            'status' => true,
            'message' => 'Brand deleted successfully'
        ]);
    }
}