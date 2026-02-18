<?php

namespace App\Repository\Interfaces;

use App\DTOs\Auth\LoginDTO;

interface LoginInterface{
    public function login(LoginDTO $credentials): array;
    public function logout(): void;
}
