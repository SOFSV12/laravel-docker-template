<?php

namespace App\Http\Controllers\API\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Services\Auth\ResetPasswordService;
use App\Traits\ResponseTrait;
use Symfony\Component\HttpFoundation\Response;

class ResetPasswordController extends Controller
{
    use ResponseTrait;

    public function __construct(protected ResetPasswordService $service){
    }

    public function resetPassword(ResetPasswordRequest $request)
    {
        $data =  $this->service->resetPassword($request->toDto());

        return $this->successResponse(data: $data, statusCode: $data['success'] ? Response::HTTP_OK : Response::HTTP_UNPROCESSABLE_ENTITY);

    }
}
