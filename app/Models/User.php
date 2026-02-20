<?php

namespace App\Models;


use App\Models\Ngo\Ngo;
use Laravel\Sanctum\HasApiTokens;
use App\Models\Volunteer\Volunteer;
use Illuminate\Contracts\Auth\CanResetPassword;
use Illuminate\Notifications\Notifiable;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable implements MustVerifyEmail, CanResetPassword
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens, HasUuids;

    protected $primaryKey = 'uuid';

    public $incrementing = false;

    protected $keyType = 'string';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'password',
        'user_type'
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Setup one to one Rrelationship between User and Volunteer
     *
     * @return HasOne
     */
    public function volunteer(): HasOne
    {
        return $this->hasOne(Volunteer::class, 'user_id', 'uuid');
    }

    /**
     * Setup one to one Rrelationship between User and NGO
     *
     * @return HasOne
     */
    public function ngo(): HasOne
    {
        return $this->hasOne(Ngo::class, 'user_id', 'uuid');
    }

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
