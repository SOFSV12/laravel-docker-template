<?php

namespace App\Repository\Interfaces;

use App\DTOs\Auth\ResetPasswordDTO;

interface ResetPasswordInterface{
    public function resetPassword(ResetPasswordDTO $dto);
}
