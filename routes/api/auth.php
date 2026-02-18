<?php

use App\Http\Controllers\API\Auth\ForgotPasswordController;
use App\Http\Controllers\API\Auth\LoginController;
use App\Http\Controllers\API\Auth\RegisterController;
use App\Http\Controllers\API\Auth\ResetPasswordController;
use Illuminate\Foundation\Auth\EmailVerificationRequest;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::group(['prefix' => 'auth'], function () {
    //no authenthication required
    Route::post('/ngo-registration', [RegisterController::class, 'createNgo'])->name('register.ngo');
    Route::post('/volunteer-registration', [RegisterController::class, 'createVolunteer'])->name('register.volunteer');
    Route::post('/login', [LoginController::class, 'login'])->name('login');

    //email verification
    Route::get('/email/verify/{id}/{hash}', function (EmailVerificationRequest $request) {
    $request->fulfill();

        // return redirect('/home');
        return response()->json(['message' => 'Verification Succesful']);
    })->middleware(['auth:sanctum', 'signed'])->name('verification.verify');

    //resend email verification link
    Route::post('/email/verification-notification', function (Request $request) {
        $request->user()->sendEmailVerificationNotification();

        return response()->json(['message' => 'Verification link sent!']);
    })->middleware(['auth:sanctum', 'throttle:6,1'])->name('verification.send');

    //send reset password link
    Route::post('/forgot-password', [ForgotPasswordController::class, 'sendLink'])->middleware('guest')->name('password.email');

    //requires authenthication
    Route::post('/logout', [LoginController::class, 'logout'])->middleware('auth:sanctum')->name('logout');


    Route::post('/reset-password', [ResetPasswordController::class, 'resetPassword'])->middleware('guest')->name('password.update');

    Route::get('/reset-password/{token}', function ($token) {
        return response()->json([
            'token' => $token,
            'reset_url' => config('app.frontend_url') . '/reset-password?token=' . $token
        ]);
    })->middleware('guest')->name('password.reset');
    
});




