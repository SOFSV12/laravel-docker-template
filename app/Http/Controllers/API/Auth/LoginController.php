<?php

namespace App\Http\Controllers\API\Auth;


use App\Services\Auth\LoginService;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Http\Requests\Auth\LoginRequest;
use App\Traits\ResponseTrait;
use Illuminate\Support\Facades\Log;
use Laravel\Socialite\Facades\Socialite;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

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

    public function redirectToProvider($userType)
    {
        return Socialite::driver('google')->stateless()->with(['state' => $userType])->redirect();
    }

    public function handleProviderCallback(Request $request)
    {
        try {
            $userType = $request->input('state');

            $socialUser = Socialite::driver('google')
                ->stateless()
                ->user();

            $user = $this->service->handleSocialLogin($socialUser, $userType);

            $token = $user->createToken('auth_token')->plainTextToken;

            return $this->successResponse(data: [
                'user'  => $user,
                'token' => $token,
            ], message: "Login Succesful");

        } catch (Throwable $e) {
            Log::info($e->getMessage());
            return $this->errorResponse(message: 'Login Failed', statusCode: Response::HTTP_BAD_REQUEST);
        }
    }
}
