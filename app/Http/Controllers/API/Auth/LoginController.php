<?php

namespace App\Http\Controllers\API\Auth;


use App\Services\Auth\LoginService;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Http\Requests\Auth\LoginRequest;

class LoginController extends Controller
{
    public function __construct(protected LoginService $service)
    {
    }

    public function login(LoginRequest $request)
    {
        return $this->service->login($request->toDto());
    }

    public function logout(Request $request)
    {
         $this->service->logout();
         return "Succesfully logged out";
    }
}
