<?php

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../config/jwt.php';
require_once __DIR__ . '/../../config/response.php';

corsHeaders();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$auth = requireAuth();
$userId = (int) $auth['sub'];
$db = getDB();

// ── GET: list all plans for authenticated user ────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    $stmt = $db->prepare(
        'SELECT * FROM plans WHERE user_id = ? ORDER BY created_at DESC'
    );
    $stmt->execute([$userId]);
    $plans = $stmt->fetchAll();

    foreach ($plans as &$plan) {
        $planId = (int) $plan['id'];

        // Fetch stops
        $s = $db->prepare('SELECT * FROM plan_stops WHERE plan_id = ? ORDER BY stop_order ASC');
        $s->execute([$planId]);
        $plan['stops'] = $s->fetchAll();

        // Fetch friends
        $f = $db->prepare('SELECT * FROM plan_friends WHERE plan_id = ?');
        $f->execute([$planId]);
        $plan['friends'] = $f->fetchAll();
    }
    unset($plan);

    respond(['plans' => $plans]);
}

// ── POST: create a new plan ───────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    $data = body();

    $planName       = trim($data['plan_name'] ?? '');
    $vibe           = trim($data['vibe'] ?? '');
    $outingDate     = $data['outing_date'] ?? null;
    $weatherContext = $data['weather_context'] ?? null;
    $stops          = $data['stops'] ?? [];
    $friends        = $data['friends'] ?? [];

    if (empty($planName)) {
        respondError('plan_name is required');
    }

    $db->beginTransaction();

    try {
        $stmt = $db->prepare(
            'INSERT INTO plans (user_id, plan_name, vibe, outing_date, weather_context, is_offline, created_at, updated_at)
             VALUES (?, ?, ?, ?, ?, 0, NOW(), NOW())'
        );
        $stmt->execute([$userId, $planName, $vibe, $outingDate, $weatherContext]);
        $planId = (int) $db->lastInsertId();

        // Insert stops
        if (!empty($stops)) {
            $stopStmt = $db->prepare(
                'INSERT INTO plan_stops (plan_id, place_name, place_id, latitude, longitude, arrival_time, stop_order, weather_badge, created_at)
                 VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW())'
            );
            foreach ($stops as $stop) {
                $stopStmt->execute([
                    $planId,
                    $stop['place_name'] ?? '',
                    $stop['place_id'] ?? null,
                    $stop['latitude'] ?? 0,
                    $stop['longitude'] ?? 0,
                    $stop['arrival_time'] ?? null,
                    $stop['stop_order'] ?? 0,
                    $stop['weather_badge'] ?? null,
                ]);
            }
        }

        // Insert friends
        if (!empty($friends)) {
            $friendStmt = $db->prepare(
                'INSERT INTO plan_friends (plan_id, friend_name, friend_contact, invited_at)
                 VALUES (?, ?, ?, NOW())'
            );
            foreach ($friends as $friend) {
                $friendStmt->execute([
                    $planId,
                    $friend['name'] ?? '',
                    $friend['contact'] ?? null,
                ]);
            }
        }

        $db->commit();

        // Fetch the full created plan
        $stmt = $db->prepare('SELECT * FROM plans WHERE id = ?');
        $stmt->execute([$planId]);
        $plan = $stmt->fetch();

        $s = $db->prepare('SELECT * FROM plan_stops WHERE plan_id = ? ORDER BY stop_order ASC');
        $s->execute([$planId]);
        $plan['stops'] = $s->fetchAll();

        $f = $db->prepare('SELECT * FROM plan_friends WHERE plan_id = ?');
        $f->execute([$planId]);
        $plan['friends'] = $f->fetchAll();

        respond(['plan' => $plan], 201);

    } catch (Exception $e) {
        $db->rollBack();
        respondError('Failed to create plan: ' . $e->getMessage(), 500);
    }
}

respondError('Method not allowed', 405);
