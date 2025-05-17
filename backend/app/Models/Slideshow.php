<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Slideshow extends Model
{
    protected $fillable = [
        'name',
        'description',
        'price',
        'image',
        'product_id',
        'enable',
        'link',
        'ssorder'
    ];

    protected $casts = [
        'enable' => 'boolean',
        'price' => 'decimal:2',
    ];

    /**
     * Get the product associated with the slideshow.
     */
    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
