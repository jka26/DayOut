<?php

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/response.php';

corsHeaders();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    respondError('Method not allowed', 405);
}

$data = body();

$email    = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

if (empty($email) || empty($password)) {
    respondError('Email and password are required');
}

$db = getDB();

$stmt = $db->prepare('SELECT id, name, email, password_hash, profile_photo, vibe_preference FROM users WHERE email = ?');
$stmt->execute([$email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    respondError('Invalid email or password', 401);
}

// Remove password hash from response
unset($user['password_hash']);

$token = jwtEncode(['sub' => $user['id'], 'email' => $user['email']]);

respond(['token' => $token, 'user' => $user]);
