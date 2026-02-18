<?php

namespace App\Models\Ngo;

use App\Models\User;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Ngo extends Model
{
    /** @use HasFactory<\Database\Factories\NgoFactory> */
    use HasFactory, HasUuids;

    protected $primaryKey = 'uuid';

    public $incrementing = false;

    protected $keyType = 'string';

    protected $fillable = [
        'name',
        'description',
        'category',
        'registration_number',
        'website',
        'logo',
        'cover_image_url',
        'contact_email',
        'contact_phone',
        'address_line1',
        'address_line2',
        'city',
        'state',
        'country',
        'postal_code',
        'verification_status',
        'verification_date',
        'verified_by',
        'rejection_reason',
        'risk_score',
        'subscription_tier',
        'subscription_start_date',
        'subscription_end_date',
        'auto_renew',
        'is_featured',
        'trust_badge',
        'total_volunteers_engaged',
        'total_donations_received'
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
