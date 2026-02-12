<?php

namespace App\Services\Auth;

use Throwable;
use App\Models\User;
use App\DTOs\Auth\RegisterDTO;
use Illuminate\Support\Facades\Hash;
use Illuminate\Auth\Events\Registered;
use App\Repository\Interfaces\RegisterInterface;

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
        try{
            $data=[];
            $data['email'] = $registerDto->email;
            $data['password'] = Hash::make($registerDto->password);
            $data['user_type'] = 'ngo';

            $user = $this->repository->create($data);

            // event(new Registered($user));

            $token = $this->issueToken($user, 'ngotoken');

            return ['user' => $user, 'token' => $token];

        }catch(Throwable $e){
            throw $e;
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
