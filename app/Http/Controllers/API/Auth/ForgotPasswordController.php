<?php

namespace App\Http\Controllers\API\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Services\Auth\ForgotPasswordService;
use App\Traits\ResponseTrait;

class ForgotPasswordController extends Controller
{
    use ResponseTrait;
    
    public function __construct(protected ForgotPasswordService $service)
    {
    }

    public function sendLink(ForgotPasswordRequest $request)
    {

        $link = $this->service->sendResetLink($request->toDto());

        return $this->successResponse(data: $link, message: 'Link Sent Succesfully');

    }
}
