<?php

namespace App\Http\Requests\Auth;

use App\DTOs\Auth\ResetPasswordDTO;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class   ResetPasswordRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'token' => ['required'],
            'email' => ['required', 'email'],
            'password' => ['required','string', Password::defaults(), 'confirmed'],
            'password_confirmation' => ['required','string','same:password']
        ];
    }

    public function toDto(): ResetPasswordDTO
    {
            $data = $this->validated();
    
    // Debug to see what's in the validated data
    \Log::info('Validated data:', $data);
    
        return new ResetPasswordDTO(...$this->validated());
    }
}
