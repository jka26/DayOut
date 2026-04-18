<?php

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../config/response.php';

corsHeaders();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    respondError('Method not allowed', 405);
}

$bestFor = trim($_GET['best_for'] ?? '');
$weather = trim($_GET['weather'] ?? '');

if (empty($bestFor) || empty($weather)) {
    respondError('best_for and weather query parameters are required');
}

$db = getDB();

$stmt = $db->prepare(
    'SELECT * FROM food_suggestions
     WHERE best_for = ?
       AND (weather_condition = ? OR weather_condition = \'any\')
     ORDER BY is_local DESC, RAND()
     LIMIT 8'
);
$stmt->execute([$bestFor, $weather]);
$suggestions = $stmt->fetchAll();

respond(['suggestions' => $suggestions]);
