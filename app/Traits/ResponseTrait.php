<?php 

namespace App\Traits;

use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

trait ResponseTrait{
     public function successResponse(
        mixed $data = null,
        string $message = '',
        int $statusCode = Response::HTTP_OK,
        mixed $pagination = null
    ): JsonResponse {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data,
            'pagination' => $pagination,
        ], $statusCode);
    }

    public function errorResponse(
        string $message,
        int $statusCode = Response::HTTP_BAD_REQUEST,
        mixed $errors = null
    ): JsonResponse {
        return response()->json([
            'success' => false,
            'message' => $message,
            'errors' => $errors,
        ], $statusCode);
    }
}

