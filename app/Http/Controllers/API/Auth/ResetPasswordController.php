<?php

namespace App\Http\Controllers\API\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Services\Auth\ResetPasswordService;

class ResetPasswordController extends Controller
{
    public function __construct(protected ResetPasswordService $service){
    }

    public function resetPassword(ResetPasswordRequest $request)
    {
        $response =  $this->service->resetPassword($request->toDto());

        return response()->json($response, $response['success'] ? 200 : 422);
    }
}
