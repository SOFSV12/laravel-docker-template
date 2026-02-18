<?php

namespace App\Services\Auth;

use App\DTOs\Auth\ForgotPasswordDTO;
use App\Repository\Interfaces\ForgotPasswordInterface;
use Illuminate\Support\Facades\Password;

final class ForgotPasswordService implements ForgotPasswordInterface {

    public function sendResetLink(ForgotPasswordDTO $data)
    {
        $status = Password::sendResetLink(['email' => $data->email]);

        return $status === Password::ResetLinkSent
            ? back()->with(['status' => __($status)])
            : back()->withErrors(['email' => __($status)]);
    }

}
