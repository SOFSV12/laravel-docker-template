<?php

namespace App\Services\Auth;

use App\DTOs\Auth\RegisterDTO;
use App\Models\User;
use App\Repository\Interfaces\RegisterInterface;
use Illuminate\Auth\Events\Registered;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Throwable;

class RegisterService{

    public function __construct(protected RegisterInterface $repository){
    }

    /**
     * Create a user with type NGO.
     *
     * @param RegisterDTO $registerDto
     * @return User
     */
    public function createNgo(RegisterDTO $registerDto)
    {
        try {
            $data = [
                'email' => $registerDto->email,
                'password' => Hash::make($registerDto->password),
                'user_type' => 'ngo'
            ];

            $user = $this->repository->create($data);

            event(new Registered($user));

            $token = $this->issueToken($user, 'ngotoken');

            return ['user' => $user, 'token' => $token];

        } catch (Throwable $e) {
            // Log first, then throw
            Log::error('Exception occurred', [
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString()
            ]);
        }
    }

    /**
     * Create a user with type VOLUNTEER.
     *
     * @param RegisterDTO $registerDto
     * @return User
     */
    public function createVolunteer(RegisterDTO $registerDto)
    {
        try{
            $data=[];
            $data['email'] = $registerDto->email;
            $data['password'] = Hash::make($registerDto->password);
            $data['user_type'] = 'volunteer';

            $user = $this->repository->create($data);

             event(new Registered($user));

            $token = $this->issueToken($user, 'volunteertoken');

            return ['user' => $user, 'token' => $token];

        }catch(Throwable $e){
            throw $e;
        }
    }

    /**
     * Isue plainTextToken
     *
     * @param User $user
     * @param string $name
     * @return void
     */
    public function issueToken(User $user, string $name)
    {
        return $user->createToken($name)->plainTextToken;
    }
}
