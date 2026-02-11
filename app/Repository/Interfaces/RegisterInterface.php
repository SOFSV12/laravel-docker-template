<?php

namespace app\Repository\Interfaces;

use App\Models\User;

interface RegisterInterface{
    public function create(array $data): User;
}
