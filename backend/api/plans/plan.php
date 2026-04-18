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
$planId = (int) ($_GET['id'] ?? 0);

if ($planId <= 0) {
    respondError('A valid plan id is required');
}

$db = getDB();

// Verify the plan belongs to the authenticated user
$stmt = $db->prepare('SELECT * FROM plans WHERE id = ? AND user_id = ?');
$stmt->execute([$planId, $userId]);
$plan = $stmt->fetch();

if (!$plan) {
    respondError('Plan not found', 404);
}

// ── GET: return plan + stops + friends + saved_facts ─────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'GET') {

    $s = $db->prepare('SELECT * FROM plan_stops WHERE plan_id = ? ORDER BY stop_order ASC');
    $s->execute([$planId]);
    $plan['stops'] = $s->fetchAll();

    $f = $db->prepare('SELECT * FROM plan_friends WHERE plan_id = ?');
    $f->execute([$planId]);
    $plan['friends'] = $f->fetchAll();

    $facts = $db->prepare('SELECT * FROM saved_facts WHERE plan_id = ?');
    $facts->execute([$planId]);
    $plan['saved_facts'] = $facts->fetchAll();

    respond(['plan' => $plan]);
}

// ── PUT: update plan fields ───────────────────────────────────────────────────
if ($_SERVER['REQUEST_METHOD'] === 'PUT') {

    $data = body();

    $allowed = ['plan_name', 'vibe', 'outing_date', 'weather_context', 'is_offline'];
    $setClauses = [];
    $params = [];

    foreach ($allowed as $field) {
        if (array_key_exists($field, $data)) {
            $setClauses[] = "{$field} = ?";
            $params[] = $data[$field];
        }
    }

    if (empty($setClauses)) {
        respondError('No updatable fields provided');
    }

    $setClauses[] = 'updated_at = NOW()';
    $params[] = $planId;
    $params[] = $userId;

    $sql = 'UPDATE plans SET ' . implode(', ', $setClauses) . ' WHERE id = ? AND user_id = ?';
    $stmt = $db->prepare($sql);
    $stmt->execute($params);

    // Return the updated plan
    $stmt = $db->prepare('SELECT * FROM plans WHERE id = ?');
    $stmt->execute([$planId]);
    $updated = $stmt->fetch();

    respond(['plan' => $updated]);
}

// ── DELETE: delete plan (cascade handles stops/friends/facts) ─────────────────
if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {

    $stmt = $db->prepare('DELETE FROM plans WHERE id = ? AND user_id = ?');
    $stmt->execute([$planId, $userId]);

    respond(['message' => 'Plan deleted successfully']);
}

respondError('Method not allowed', 405);
