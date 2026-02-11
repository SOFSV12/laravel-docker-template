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
        Schema::create('ngos', function (Blueprint $table) {
            //org information
            $table->uuid()->primary();
            $table->foreignUuid('user_id')->nullable()->references('uuid')->on('users')->cascadeOnDelete();
            $table->string('name');
            $table->text('description');
            $table->string('category');
            $table->string('registration_number');
            $table->string('website', 255);
            $table->text('logo');
            $table->text('cover_image_url');

            //contanct information
            $table->string('contact_email');
            $table->string('contact_phone', 100);
            $table->string('address_line1');
            $table->string('address_line2');
            $table->string('city');
            $table->string('state');
            $table->string('country')->default('Nigeria');
            $table->string('postal_code', 20);

            //verification
            $table->enum('verification_status',['pending', 'under_review', 'verified', 'rejected', 'suspended'])->default('pending');
            $table->timestamp('verification_date');
            $table->foreignUuid('verified_by')->nullable()->references('uuid')->on('users')->cascadeOnDelete();
            $table->text('rejection_reason');
            $table->integer('risk_score'); //minimum value of o and maximum of 100, validation would handle

            //subscription
            $table->enum('subscription_tier', ['free', 'premium']);
            $table->timestamp('subscription_start_date');
            $table->timestamp('subscription_end_date');
            $table->boolean('auto_renew')->default(false);

            $table->boolean('is_featured')->default(false);
            $table->boolean('trust_badge')->default(false);
            $table->integer('total_volunteers_engaged')->default(0);
            $table->float('total_donations_received')->default(0.00);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ngos');
    }
};
