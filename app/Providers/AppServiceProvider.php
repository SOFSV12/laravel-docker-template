<?php

namespace App\Providers;


use Illuminate\Support\ServiceProvider;
use App\Repository\Interfaces\RegisterInterface;
use App\Repository\RegisterRepository;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->app->bind(RegisterInterface::class, RegisterRepository::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }
}
