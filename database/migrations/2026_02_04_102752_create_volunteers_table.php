<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('volunteers', function (Blueprint $table) {
            //personal info
            $table->uuid()->primary();
            $table->foreignUuid('user_id')->references('uuid')->on('users')->cascadeOnDelete();
            $table->string('first_mame');
            $table->string('last_name');
            $table->text('profile_photo_url');
            $table->string('gender');
            $table->date('date_of_birth');
            $table->string('occupation');
            $table->text('bio');

            //location information
            $table->string('country');
            $table->string('state');
            $table->string('city');

            //statistics
            $table->integer('total_hours')->default(0);
            $table->integer('total_causes_completed')->default(0);
            $table->decimal('total_donations_made', 15, 2)->default(0.00);
            $table->enum('badge_level', ['bronze', 'silver', 'gold', 'platinum'])->default('bronze');

            //timestamp
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('volunteers');
    }
};
