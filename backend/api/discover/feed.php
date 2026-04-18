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

$lat   = (float) ($_GET['lat'] ?? 0);
$lng   = (float) ($_GET['lng'] ?? 0);
$limit = min((int) ($_GET['limit'] ?? 20), 50);

if ($limit <= 0) {
    $limit = 20;
}

$db = getDB();

// Haversine distance in SQL, ordered by visit_count DESC
$sql = '
    SELECT *,
        (6371 * ACOS(
            COS(RADIANS(:lat)) * COS(RADIANS(latitude)) *
            COS(RADIANS(longitude) - RADIANS(:lng)) +
            SIN(RADIANS(:lat2)) * SIN(RADIANS(latitude))
        )) AS distance_km
    FROM discover_feed
    ORDER BY visit_count DESC
    LIMIT :lim
';

$stmt = $db->prepare($sql);
$stmt->bindValue(':lat',  $lat,   PDO::PARAM_STR);
$stmt->bindValue(':lng',  $lng,   PDO::PARAM_STR);
$stmt->bindValue(':lat2', $lat,   PDO::PARAM_STR);
$stmt->bindValue(':lim',  $limit, PDO::PARAM_INT);
$stmt->execute();

$feed = $stmt->fetchAll();

respond(['feed' => $feed]);
