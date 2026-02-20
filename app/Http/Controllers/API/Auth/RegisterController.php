<?php

namespace App\Http\Controllers\API\Auth;

use Illuminate\Http\Response;
use App\Http\Controllers\Controller;
use App\Services\Auth\RegisterService;
use App\Http\Requests\Auth\RegisterRequest;
use App\Traits\ResponseTrait;

class RegisterController extends Controller
{
    use ResponseTrait;

    public function __construct(protected RegisterService $service){}

    public function createNgo(RegisterRequest $request)
    {
        $user = $this->service->createNgo($request->toDto());

        return $this->successResponse(message: 'NGO Created Succesfully', data: $user, statusCode: Response::HTTP_CREATED);
    }

    public function createVolunteer(RegisterRequest $request)
    {
        $user = $this->service->createVolunteer($request->toDto());

        $this->successResponse(message: 'Volunteer created Successfuly', data: $user, statusCode: Response::HTTP_CREATED);

    }
}
