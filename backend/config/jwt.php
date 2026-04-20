<?php

/**
 * Stateless JWT implementation (HS256, no external library).
 */

function base64UrlEncode(string $data): string
{
    return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

function base64UrlDecode(string $data): string
{
    $padded = str_pad(strtr($data, '-_', '+/'), strlen($data) + (4 - strlen($data) % 4) % 4, '=');
    return base64_decode($padded);
}

function jwtEncode(array $payload): string
{
    $secret = getenv('JWT_SECRET') ?: ($_ENV['JWT_SECRET'] ?? '');
    if (empty($secret)) { http_response_code(500); echo json_encode(['error' => 'JWT_SECRET not configured']); exit; }

    $header = base64UrlEncode(json_encode(['alg' => 'HS256', 'typ' => 'JWT']));

    // Add 30-day expiry automatically
    $payload['exp'] = $payload['exp'] ?? (time() + 30 * 24 * 60 * 60);
    $payload['iat'] = $payload['iat'] ?? time();

    $encodedPayload = base64UrlEncode(json_encode($payload));

    $signature = base64UrlEncode(
        hash_hmac('sha256', "{$header}.{$encodedPayload}", $secret, true)
    );

    return "{$header}.{$encodedPayload}.{$signature}";
}

function jwtDecode(string $token): ?array
{
    $secret = getenv('JWT_SECRET') ?: ($_ENV['JWT_SECRET'] ?? '');
    if (empty($secret)) return null;

    $parts = explode('.', $token);
    if (count($parts) !== 3) {
        return null;
    }

    [$header, $encodedPayload, $signature] = $parts;

    // Verify signature
    $expectedSignature = base64UrlEncode(
        hash_hmac('sha256', "{$header}.{$encodedPayload}", $secret, true)
    );

    if (!hash_equals($expectedSignature, $signature)) {
        return null;
    }

    $payload = json_decode(base64UrlDecode($encodedPayload), true);
    if (!is_array($payload)) {
        return null;
    }

    // Check expiry
    if (isset($payload['exp']) && $payload['exp'] < time()) {
        return null;
    }

    return $payload;
}

function requireAuth(): array
{
    $headers = getallheaders();
    $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

    if (!str_starts_with($authHeader, 'Bearer ')) {
        http_response_code(401);
        echo json_encode(['error' => 'Unauthorized: missing token']);
        exit;
    }

    $token = substr($authHeader, 7);
    $payload = jwtDecode($token);

    if ($payload === null) {
        http_response_code(401);
        echo json_encode(['error' => 'Unauthorized: invalid or expired token']);
        exit;
    }

    return $payload;
}
