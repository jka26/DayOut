<?php

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/response.php';

corsHeaders();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    respondError('Method not allowed', 405);
}

$auth = requireAuth();

$db = getDB();

$stmt = $db->prepare(
    'SELECT id, name, email, profile_photo, vibe_preference FROM users WHERE id = ?'
);
$stmt->execute([$auth['sub']]);
$user = $stmt->fetch();

if (!$user) {
    respondError('User not found', 404);
}

respond(['user' => $user]);
