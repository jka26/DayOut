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

$name     = trim($data['name'] ?? '');
$email    = trim($data['email'] ?? '');
$password = $data['password'] ?? '';

// Validate required fields
if (empty($name)) {
    respondError('Name is required');
}

if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
    respondError('A valid email address is required');
}

if (strlen($password) < 8) {
    respondError('Password must be at least 8 characters');
}

$db = getDB();

// Check email uniqueness
$stmt = $db->prepare('SELECT id FROM users WHERE email = ?');
$stmt->execute([$email]);
if ($stmt->fetch()) {
    respondError('An account with that email already exists', 409);
}

// Hash password and insert user
$hash = password_hash($password, PASSWORD_BCRYPT);
$stmt = $db->prepare(
    'INSERT INTO users (name, email, password_hash, created_at, updated_at) VALUES (?, ?, ?, NOW(), NOW())'
);
$stmt->execute([$name, $email, $hash]);
$userId = (int) $db->lastInsertId();

// Fetch the created user
$stmt = $db->prepare('SELECT id, name, email, profile_photo, vibe_preference, created_at FROM users WHERE id = ?');
$stmt->execute([$userId]);
$user = $stmt->fetch();

$token = jwtEncode(['sub' => $userId, 'email' => $email]);

respond(['token' => $token, 'user' => $user], 201);
