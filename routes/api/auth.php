<?php

use App\Http\Controllers\API\Auth\LoginController;
use App\Http\Controllers\API\Auth\RegisterController;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'auth'], function () {
    //no authenthication required
    Route::post('/ngo-registration', [RegisterController::class, 'createNgo'])->name('register.ngo');
    Route::post('/volunteer-registration', [RegisterController::class, 'createVolunteer'])->name('register.volunteer');
    Route::post('/login', [LoginController::class, 'login'])->name('login');

    //requires authenthication
    Route::post('/logout', [LoginController::class, 'logout'])->middleware('auth:sanctum')->name('logout');
});

Route::get('/email/verify/{id}/{hash}', function (EmailVerificationRequest $request) {
    $request->fulfill();

    // return redirect('/home');
    return response()->json(['message' => 'Verification Succesful']);
})->middleware(['auth:sanctum', 'signed'])->name('verification.verify');


Route::post('/email/verification-notification', function (Request $request) {
    $request->user()->sendEmailVerificationNotification();

    return response()->json(['message' => 'Verification link sent!']);
})->middleware(['auth:sanctum', 'throttle:6,1'])->name('verification.send');
