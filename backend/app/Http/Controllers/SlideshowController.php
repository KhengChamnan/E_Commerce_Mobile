<?php

namespace App\Http\Controllers;

use App\Models\Slideshow;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage; // Add this import

class SlideshowController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $slideshows = Slideshow::with('product')->orderBy('ssorder')->get();
        
        return response()->json([
            'status' => true,
            'slideshows' => $slideshows
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'price' => 'required|numeric|min:0',
            'product_id' => 'required|exists:products,id',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'enable' => 'nullable|boolean',
            'link' => 'nullable|string|url',
            'ssorder' => 'nullable|integer|min:0'
        ]);

        if($validator->fails()){
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $imagePath = null;
        if ($request->hasFile('image')) {
            $image = $request->file('image');
            $filename = 'slideshow_' . time() . '.' . $image->getClientOriginalExtension();
            // Store in storage/app/public/slideshows directory
            Storage::disk('public')->putFileAs('slideshows', $image, $filename);
            $imagePath = $filename; // Store full path relative to storage/app/public
        }

        $slideshow = Slideshow::create([
            'name' => $request->name,
            'description' => $request->description,
            'price' => $request->price,
            'image' => $imagePath,
            'product_id' => $request->product_id,
            'enable' => $request->has('enable') ? $request->enable : true,
            'link' => $request->link,
            'ssorder' => $request->ssorder ?? 0
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Slideshow created successfully',
            'slideshow' => $slideshow
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Slideshow $slideshow)
    {
        $slideshow->load('product');
        
        return response()->json([
            'status' => true,
            'slideshow' => $slideshow
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Slideshow $slideshow)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'price' => 'sometimes|required|numeric|min:0',
            'product_id' => 'sometimes|required|exists:products,id',
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'enable' => 'nullable|boolean',
            'link' => 'nullable|string|url',
            'ssorder' => 'nullable|integer|min:0'
        ]);

        if($validator->fails()){
            return response()->json([
                'status' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $data = $request->only(['name', 'description', 'price', 'product_id', 'enable', 'link', 'ssorder']);

        if ($request->hasFile('image')) {
            if ($slideshow->image) {
                // Delete old image if exists
                Storage::disk('public')->delete($slideshow->image); // Remove 'slideshows/' since full path is stored
            }
            
            $image = $request->file('image');
            $filename = 'slideshow_' . time() . '.' . $image->getClientOriginalExtension();
            // Store in storage/app/public/slideshows directory
            Storage::disk('public')->putFileAs('slideshows', $image, $filename);
            $data['image'] = $filename; // Store full path relative to storage/app/public
        }

        $slideshow->update($data);

        return response()->json([
            'status' => true,
            'message' => 'Slideshow updated successfully',
            'slideshow' => $slideshow
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Slideshow $slideshow)
    {
        // Delete slideshow image if exists
        if ($slideshow->image) {
            Storage::disk('public')->delete($slideshow->image); // Remove 'slideshows/' since full path is stored
        }
        
        $slideshow->delete();

        return response()->json([
            'status' => true,
            'message' => 'Slideshow deleted successfully'
        ]);
    }
    
    /**
     * Get active slideshows for the mobile app.
     */
    public function getActiveSlides()
    {
        $slideshows = Slideshow::where('enable', true)
                      ->orderBy('ssorder')
                      ->with('product')
                      ->get();
        
        return response()->json([
            'status' => true,
            'slideshows' => $slideshows
        ]);
    }
}