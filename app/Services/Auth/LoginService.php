<?php

namespace App\Services\Auth;

use App\Models\User;
use App\DTOs\Auth\LoginDTO;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Hash;
use App\Repository\Interfaces\LoginInterface;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

final class LoginService implements LoginInterface{

    public function login(LoginDTO $data): array
    {
        $user = User::where('email', $data->email)
                ->first();

        Log::info(['user' => $user]);

        if(!$user || !Hash::check($data->password, $user->password)){
            throw ValidationException::withMessages([
                'identifier' => trans('auth.failed'),
            ]);
        }

        $user->tokens()->delete();

        return [
            'user'  => $user,
            'token' => $user->createToken('login')->plainTextToken
        ];
    }

    public function logout():void
    {
        $user = auth()->user();

        if ($user) {
            $user->currentAccessToken()->delete();
        }

    }

    public function handleSocialLogin($socialUser, string $userType): User
    {
        return User::updateOrCreate(
            ['email' => $socialUser->getEmail()],
            [
                'name'              => $socialUser->getName(),
                'provider_id'       => $socialUser->getId(),
                'provider'          => 'google',
                'user_type'         => $userType,
                'password'          => Hash::make(Str::random(40)),
                'email_verified_at' => now(),
            ]
        );
    }

}
