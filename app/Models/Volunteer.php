<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Volunteer extends Model
{
    /** @use HasFactory<\Database\Factories\VolunteerFactory> */
    use HasFactory, HasUuids;

    protected $primaryKey = 'uuid';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'first_name',
        'last_name',
        'profile_photo_url',
        'gender',
        'date_of_birth',
        'occupation',
        'bio',
        'country',
        'state',
        'city',
        'total_hours',
        'total_causes_completed',
        'total_donations_made',
        'badge_level'
    ];

    /**
     * Inverse one to one relationship to User Model
     *
     * @return BelongsTo
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id', 'uuid');
    }

}
