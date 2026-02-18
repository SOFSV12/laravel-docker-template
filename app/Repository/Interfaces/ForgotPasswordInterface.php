<?php

namespace App\Repository\Interfaces;

use App\DTOs\Auth\ForgotPasswordDTO;

interface ForgotPasswordInterface{
    public function sendResetLink(ForgotPasswordDTO $dto);
}
