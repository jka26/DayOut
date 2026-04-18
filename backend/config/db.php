<?php

/**
 * Database connection helper.
 * Reads DB_HOST, DB_NAME, DB_USER, DB_PASS from environment variables.
 * Exposes getDB(): PDO using a static singleton.
 */

function getDB(): PDO
{
    static $pdo = null;

    if ($pdo !== null) {
        return $pdo;
    }

    $host = getenv('DB_HOST') ?: $_ENV['DB_HOST'] ?? 'localhost';
    $name = getenv('DB_NAME') ?: $_ENV['DB_NAME'] ?? 'dayout';
    $user = getenv('DB_USER') ?: $_ENV['DB_USER'] ?? 'root';
    $pass = getenv('DB_PASS') ?: $_ENV['DB_PASS'] ?? '';

    $dsn = "mysql:host={$host};dbname={$name};charset=utf8mb4";

    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
    ];

    $pdo = new PDO($dsn, $user, $pass, $options);

    return $pdo;
}
