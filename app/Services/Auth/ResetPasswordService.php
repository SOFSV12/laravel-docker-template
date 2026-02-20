<?php

namespace App\Services\Auth;

use App\Models\User;
use App\Repository\Interfaces\ResetPasswordInterface;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Auth\Events\PasswordReset;
use Illuminate\Support\Str;
use App\DTOs\Auth\ResetPasswordDTO;

class ResetPasswordService implements ResetPasswordInterface {
     public function resetPassword(ResetPasswordDTO $data)
    {
        $status = Password::reset([
            'email'    => $data->email,
            'password' => $data->password,
            'password_confirmation' => $data->password_confirmation,
            'token'    => $data->token,
        ], function (User $user, string $password){
            $user->forceFill([
                'password' => Hash::make($password),
            ])->setRememberToken(Str::random(60));

            $user->save();

            event(new PasswordReset($user));
        });

        return $status === Password::PASSWORD_RESET ? ['success' => true, 'message' => __($status),] : ['success' => false, 'message' => __($status),];

    }
}
