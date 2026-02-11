<?php

namespace App\Repository;

use App\Models\User;
use Illuminate\Support\Facades\Log;
use App\Repository\Interfaces\RegisterInterface;

class RegisterRepository implements RegisterInterface
{
    public function __construct(protected User $model){
    }

    public function create(array $data): User
    {
        Log::info("logging from register repository");
       return  $this->model::create($data);
    }

}
