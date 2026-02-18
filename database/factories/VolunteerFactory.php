<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Volunteer>
 */
class VolunteerFactory extends Factory
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
            //personal info
            'first_name' => fake()->firstName($gender),
            'last_name'  => fake()->lastName(),
            'profile_photo_url' => fake()->imageUrl(width: 640, height: 480, randomize: true),
            'gender' => fake()->randomElement($gender),
            'birth_date' => fake()
            ->dateTimeBetween()
            ->format('Y-m-d'),
            'occupation' => fake()->jobTitle(),
            'bio'  => fake()->paragraphs(),

            //location
            'country' => 'Nigeria',
            'state'   =>  fake()->state(),
            'city'    =>  fake()->cityName(),

            //statistics
            'total_hours' => fake()->numberBetween(4, 22),
            'total_causes_completed' => fake()->numberBetween(3,6),
            'total_donations_made'  => fake()->randomFloat(2),
            'badge_level' => fake()->randomElement(['bronze', 'silver', 'gold', 'platinum']),
            'created_at'  => fake()->dateTimeThisMonth('+12 days')
        ];
    }
}
