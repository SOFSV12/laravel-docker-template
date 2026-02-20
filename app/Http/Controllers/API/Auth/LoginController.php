<?php

namespace App\Http\Controllers\API\Auth;


use App\Services\Auth\LoginService;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Http\Requests\Auth\LoginRequest;
use App\Traits\ResponseTrait;

class LoginController extends Controller
{
    use ResponseTrait;

    public function __construct(protected LoginService $service)
    {
    }

    public function login(LoginRequest $request)
    {
        $user = $this->service->login($request->toDto());

        return $this->successResponse(data: $user);
    }

    public function logout(Request $request)
    {
         $this->service->logout();
         
         return $this->successResponse(message: "Succesfully logged out");
    }
}
