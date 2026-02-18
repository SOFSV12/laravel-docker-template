<?php

namespace App\DTOs\Auth;

class ResetPasswordDTO{
    public function __construct(
         public readonly string $token,
         public readonly string $email,
         public readonly string $password,
         public readonly string $password_confirmation,
    ){
    }
}
