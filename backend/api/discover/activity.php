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

$auth = requireAuth();

$data = body();

$placeId       = trim($data['place_id'] ?? '');
$placeName     = trim($data['place_name'] ?? '');
$latitude      = (float) ($data['latitude'] ?? 0);
$longitude     = (float) ($data['longitude'] ?? 0);
$placeCategory = trim($data['place_category'] ?? '');
$action        = $data['action'] ?? 'visit';
$moodTags      = $data['mood_tags'] ?? '';

if (empty($placeId) || empty($placeName)) {
    respondError('place_id and place_name are required');
}

if (!in_array($action, ['visit', 'save'], true)) {
    respondError('action must be "visit" or "save"');
}

$db = getDB();

if ($action === 'visit') {
    $sql = '
        INSERT INTO discover_feed
            (place_id, place_name, latitude, longitude, place_category, visit_count, save_count, mood_tags, last_visited, updated_at)
        VALUES
            (:place_id, :place_name, :lat, :lng, :category, 1, 0, :mood_tags, NOW(), NOW())
        ON DUPLICATE KEY UPDATE
            visit_count  = visit_count + 1,
            last_visited = NOW(),
            updated_at   = NOW(),
            mood_tags    = IF(:mood_tags2 <> \'\', :mood_tags3, mood_tags)
    ';
    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':place_id'   => $placeId,
        ':place_name' => $placeName,
        ':lat'        => $latitude,
        ':lng'        => $longitude,
        ':category'   => $placeCategory,
        ':mood_tags'  => $moodTags,
        ':mood_tags2' => $moodTags,
        ':mood_tags3' => $moodTags,
    ]);
} else {
    // action === 'save'
    $sql = '
        INSERT INTO discover_feed
            (place_id, place_name, latitude, longitude, place_category, visit_count, save_count, mood_tags, last_visited, updated_at)
        VALUES
            (:place_id, :place_name, :lat, :lng, :category, 0, 1, :mood_tags, NOW(), NOW())
        ON DUPLICATE KEY UPDATE
            save_count = save_count + 1,
            updated_at = NOW(),
            mood_tags  = IF(:mood_tags2 <> \'\', :mood_tags3, mood_tags)
    ';
    $stmt = $db->prepare($sql);
    $stmt->execute([
        ':place_id'   => $placeId,
        ':place_name' => $placeName,
        ':lat'        => $latitude,
        ':lng'        => $longitude,
        ':category'   => $placeCategory,
        ':mood_tags'  => $moodTags,
        ':mood_tags2' => $moodTags,
        ':mood_tags3' => $moodTags,
    ]);
}

respond(['message' => 'Activity recorded']);
