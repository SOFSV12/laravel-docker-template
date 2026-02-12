<?php

use App\Http\Controllers\API\Auth\LoginController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\Auth\RegisterController;


Route::group(['prefix' => 'auth'], function () {
    //no authenthication required
    Route::post('/ngo-registration', [RegisterController::class, 'createNgo'])->name('register.ngo');
    Route::post('/volunteer-registration', [RegisterController::class, 'createVolunteer'])->name('register.volunteer');
    Route::post('/login', [LoginController::class, 'login'])->name('login');

    //requires authenthication
    Route::post('/logout', [LoginController::class, 'logout'])->middleware('auth:sanctum')->name('login');
});
