import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    vus: 100, // 100 concurrent Virtual Users
    duration: '1m', // Run for 1 minute continuously
    thresholds: {
        http_req_duration: ['p(95)<2000'], // 95% of requests should be below 2000ms
        http_req_failed: ['rate<0.05'],    // Less than 5% errors
    },
};

const BASE_URL = __ENV.API_BASE_URL || 'https://lifeledger-backend.onrender.com';

const endpoints = [
    '/dashboard/1/',
    '/analytics/1/',
    '/lifescore/1/',
    '/expenses/1/',
    '/income/1/',
    '/habits/1/',
    '/tasks/1/',
    '/mood/1/',
    '/history/1/',
    '/budget/1/',
    '/predictor/1/',
    '/compare/1/',
    '/alerts/1/',
    '/behavior/1/',
    '/smart-alerts/1/',
    '/goals/1/',
    '/daily-summary/1/',
    '/heatmap/1/',
    '/networth/1/',
    '/streaks/1/',
    '/achievements/1/'
];

export default function () {
    const ep = endpoints[Math.floor(Math.random() * endpoints.length)];
    const res = http.get(`${BASE_URL}${ep}`);

    check(res, {
        'status is valid': (r) => r.status >= 200 && r.status < 500,
    });

    sleep(0.05); // Minimal think time
}
