<?php

namespace App\Http\Controllers\API\Auth;

use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;
use App\Http\Controllers\Controller;
use App\Services\Auth\RegisterService;
use App\Http\Requests\Auth\RegisterRequest;


class RegisterController extends Controller
{
    public function __construct(protected RegisterService $service){}

    public function createNgo(RegisterRequest $request)
    {
        Log::info("Logging from creat NGO");

        $user = $this->service->createNgo($request->toDto());

        return response()->json(['message' => 'NGO created successfully', 'data' => $user ], Response::HTTP_CREATED);
    }

    public function createVolunteer(RegisterRequest $request)
    {
        Log::info("Logging from creat NGO");

        $user = $this->service->createVolunteer($request->toDto());

        return response()->json(['message' => 'Volunteer created successfully', 'data' => $user ], Response::HTTP_CREATED);
    }
}
