<?php

namespace App\Repository\Interfaces;

use App\DTOs\Auth\LoginDTO;
use Illuminate\Http\Request;

interface LoginInterface{
    public function login(LoginDTO $credentials): array;
    public function logout(): void;
}
