<?php

namespace App\Http\Controllers\API\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Services\Auth\ForgotPasswordService;

class ForgotPasswordController extends Controller
{
    public function __construct(protected ForgotPasswordService $service)
    {
    }

    public function sendLink(ForgotPasswordRequest $request)
    {

        $link = $this->service->sendResetLink($request->toDto());

        return response()->json([
            'data' => $link,
            'message' => "Link sent succesfully"
        ]);

    }
}
