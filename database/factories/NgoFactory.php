<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Ngo>
 */
class NgoFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $gender = fake()->randomElement(['male', 'female']);

        return [
            'name' => fake()->firstName($gender),
            'description' => fake()->paragraphs(),
            'category' => fake()->randomElement(['tech', 'providing homes', 'feeding the hungry']),
            'registration_number' => fake()->numberBetween(10000, 99999),
            'website' => fake()->url(),
            'logo'    => fake()->url(),
            'cover_image_url'  => fake()->url(),

            'contact_email' => fake()->companyEmail(),
            'contact_phone' => fake()->phoneNumber(),
            'address_line1' => fake()->streetAddress(),
            'address_line1' => fake()->streetAddress(),
            'state'   =>  fake()->state(),
            'city'    =>  fake()->cityName(),
            'country' => 'Nigeria',
            'postal_code' => fake()->postcode(),

            'verification_status' => fake()->randomElement(['pending', 'under_review', 'verified', 'rejected', 'suspended']),
            'verification_date' => now(),
            'rejection_reason' => fake()->paragraphs() ,
            'verification_status' => fake()->numberBetween(0, 100),

            'subscription_tier' => fake()->randomElement(['free', 'premium']),
            'subscription_start_date' => now(),
            'subscription_end_date' => now()->addMonth(),
            'auto_renew'  => true,

            'is_featured'  => fake()->randomElement([true,false]),
            'trust_badge'  => fake()->randomElement([true,false]),
            'total_volunteers_engaged'  => fake()->numberBetween(0,100),
            'total_donations_received'  => fake()->randomFloat(),
        ];

    }
}
