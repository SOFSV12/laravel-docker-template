<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\Auth\RegisterController;


Route::group(['prefix' => 'auth'], function () {
    Route::post('/ngo-registration', [RegisterController::class, 'createNgo'])->name('register');
    Route::post('/volunteer-registration', [RegisterController::class, 'createVolunteer'])->name('register');
});
