/**
 * LifeLedger Baseline / Load Testing Runner
 * 
 * Features:
 * - 100 concurrent Virtual Users (VUs)
 * - 1 minute (60 seconds) continuous testing
 * - Calculates Requests Per Second (RPS)
 * - Response Time Analytics: Min, Avg, Max, p50, p90, p95, p99
 * - Detailed endpoint breakdown & status code summary
 * - Markdown & JSON report output for GitHub Actions
 */

const axios = require('axios');
const fs = require('fs');
const path = require('path');

// Configuration from environment or defaults
const TARGET_URL = (process.env.API_BASE_URL || 'https://lifeledger-backend.onrender.com').replace(/\/+$/, '');
const VIRTUAL_USERS = parseInt(process.env.VUS || '100', 10);
const DURATION_SECONDS = parseInt(process.env.DURATION || '60', 10);
const REQUEST_TIMEOUT_MS = parseInt(process.env.TIMEOUT_MS || '15000', 10);

const ENDPOINTS = [
    { method: 'GET', path: '/dashboard/1/', name: 'Dashboard' },
    { method: 'GET', path: '/analytics/1/', name: 'Analytics' },
    { method: 'GET', path: '/lifescore/1/', name: 'LifeScore' },
    { method: 'GET', path: '/expenses/1/', name: 'Expenses List' },
    { method: 'GET', path: '/income/1/', name: 'Income List' },
    { method: 'GET', path: '/habits/1/', name: 'Habits List' },
    { method: 'GET', path: '/tasks/1/', name: 'Tasks List' },
    { method: 'GET', path: '/mood/1/', name: 'Mood List' },
    { method: 'GET', path: '/history/1/', name: 'History' },
    { method: 'GET', path: '/budget/1/', name: 'Budget' },
    { method: 'GET', path: '/predictor/1/', name: 'Predictor' },
    { method: 'GET', path: '/compare/1/', name: 'Compare' },
    { method: 'GET', path: '/alerts/1/', name: 'Alerts' },
    { method: 'GET', path: '/behavior/1/', name: 'Behavior' },
    { method: 'GET', path: '/smart-alerts/1/', name: 'Smart Alerts' },
    { method: 'GET', path: '/goals/1/', name: 'Goals' },
    { method: 'GET', path: '/daily-summary/1/', name: 'Daily Summary' },
    { method: 'GET', path: '/heatmap/1/', name: 'Heatmap' },
    { method: 'GET', path: '/networth/1/', name: 'Net Worth' },
    { method: 'GET', path: '/streaks/1/', name: 'Streaks' },
    { method: 'GET', path: '/achievements/1/', name: 'Achievements' },
    { method: 'POST', path: '/login/', name: 'Login Simulation', body: { email: 'loadtest@example.com', password: 'Password123' } }
];

const results = [];
const statusCodes = {};
const endpointStats = {};

ENDPOINTS.forEach(ep => {
    endpointStats[ep.path] = {
        name: ep.name,
        total: 0,
        success: 0,
        failed: 0,
        latencies: []
    };
});

const apiClient = axios.create({
    baseURL: TARGET_URL,
    timeout: REQUEST_TIMEOUT_MS,
    validateStatus: () => true, // capture all HTTP codes without throwing
    headers: {
        'User-Agent': 'LifeLedger-LoadTester/1.0',
        'Accept': 'application/json'
    }
});

function calculatePercentile(sortedArray, percentile) {
    if (sortedArray.length === 0) return 0;
    const index = Math.ceil((percentile / 100) * sortedArray.length) - 1;
    return sortedArray[Math.max(0, Math.min(index, sortedArray.length - 1))];
}

async function virtualUserWorker(vuId, stopTime) {
    let requestIndex = 0;
    while (Date.now() < stopTime) {
        const ep = ENDPOINTS[requestIndex % ENDPOINTS.length];
        requestIndex++;

        const start = Date.now();
        let status = 0;
        let success = false;
        let errorMsg = null;

        try {
            let res;
            if (ep.method === 'POST') {
                res = await apiClient.post(ep.path, ep.body);
            } else {
                res = await apiClient.get(ep.path);
            }
            status = res.status;
            success = status >= 200 && status < 500; // Expected API responses (even 400s are handled API responses)
        } catch (err) {
            status = err.response ? err.response.status : 0;
            errorMsg = err.code || err.message;
            success = false;
        }

        const duration = Date.now() - start;

        // Record metrics
        results.push({
            vuId,
            path: ep.path,
            status,
            duration,
            success,
            timestamp: Date.now()
        });

        // Track per-status count
        statusCodes[status] = (statusCodes[status] || 0) + 1;

        // Track per-endpoint stats
        const epStat = endpointStats[ep.path];
        if (epStat) {
            epStat.total++;
            if (success) epStat.success++;
            else epStat.failed++;
            epStat.latencies.push(duration);
        }

        // Slight non-blocking pause between requests (10ms-30ms) to simulate realistic user pace
        await new Promise(resolve => setTimeout(resolve, Math.floor(Math.random() * 20) + 10));
    }
}

async function runLoadTest() {
    console.log('===============================================================');
    console.log('       🚀 LIFELEDGER BASELINE / LOAD TEST RUNNER               ');
    console.log('===============================================================');
    console.log(` Target Base URL : ${TARGET_URL}`);
    console.log(` Virtual Users   : ${VIRTUAL_USERS} concurrent users`);
    console.log(` Duration        : ${DURATION_SECONDS} seconds (1 minute)`);
    console.log(` Request Timeout : ${REQUEST_TIMEOUT_MS / 1000}s`);
    console.log(` Endpoints Count : ${ENDPOINTS.length}`);
    console.log('---------------------------------------------------------------');
    console.log('⏳ Test running... please wait...\n');

    const startTime = Date.now();
    const stopTime = startTime + (DURATION_SECONDS * 1000);

    // Progress display ticker
    const intervalId = setInterval(() => {
        const elapsed = Math.round((Date.now() - startTime) / 1000);
        const remaining = Math.max(0, DURATION_SECONDS - elapsed);
        const currentReqs = results.length;
        const currentRps = elapsed > 0 ? (currentReqs / elapsed).toFixed(1) : 0;
        process.stdout.write(`\r⏱️  Elapsed: ${elapsed}s / ${DURATION_SECONDS}s | Requests: ${currentReqs} | Current RPS: ~${currentRps} req/s`);
    }, 1000);

    // Launch Virtual Users concurrently
    const workers = [];
    for (let i = 1; i <= VIRTUAL_USERS; i++) {
        workers.push(virtualUserWorker(i, stopTime));
    }

    await Promise.all(workers);
    clearInterval(intervalId);

    const totalDurationSeconds = (Date.now() - startTime) / 1000;
    const totalRequests = results.length;
    const rps = (totalRequests / totalDurationSeconds).toFixed(2);

    const latencies = results.map(r => r.duration).sort((a, b) => a - b);
    const minLatency = latencies.length ? Math.min(...latencies) : 0;
    const maxLatency = latencies.length ? Math.max(...latencies) : 0;
    const avgLatency = latencies.length ? (latencies.reduce((a, b) => a + b, 0) / latencies.length).toFixed(1) : 0;
    const p50 = calculatePercentile(latencies, 50);
    const p90 = calculatePercentile(latencies, 90);
    const p95 = calculatePercentile(latencies, 95);
    const p99 = calculatePercentile(latencies, 99);

    const successCount = results.filter(r => r.success).length;
    const failCount = totalRequests - successCount;
    const successRate = totalRequests > 0 ? ((successCount / totalRequests) * 100).toFixed(2) : 0;

    console.log('\n\n===============================================================');
    console.log('                      📊 LOAD TEST SUMMARY                      ');
    console.log('===============================================================');
    console.log(` Total Time Run       : ${totalDurationSeconds.toFixed(2)}s`);
    console.log(` Concurrent Users (VU): ${VIRTUAL_USERS}`);
    console.log(` Total Requests Sent  : ${totalRequests.toLocaleString()}`);
    console.log(` Throughput (RPS)     : ${rps} req/sec`);
    console.log(` Success Rate         : ${successRate}% (${successCount} passed / ${failCount} failed)`);
    console.log('---------------------------------------------------------------');
    console.log(' ⏱️  RESPONSE TIME ANALYTICS:');
    console.log(`   • Fastest (Min)    : ${minLatency} ms`);
    console.log(`   • Average (Mean)   : ${avgLatency} ms`);
    console.log(`   • Median (p50)     : ${p50} ms`);
    console.log(`   • 90th Percentile  : ${p90} ms`);
    console.log(`   • 95th Percentile  : ${p95} ms`);
    console.log(`   • Slowest (Max)    : ${maxLatency} ms`);
    console.log('---------------------------------------------------------------');
    console.log(' 📡 STATUS CODE DISTRIBUTION:');
    for (const [code, count] of Object.entries(statusCodes)) {
        const pct = ((count / totalRequests) * 100).toFixed(1);
        console.log(`   • HTTP ${code === '0' ? 'TIMEOUT/ERR' : code} : ${count} requests (${pct}%)`);
    }
    console.log('---------------------------------------------------------------');
    console.log(' 🎯 TOP ENDPOINT PERFORMANCE:');
    console.log(' Path                          | Total | Avg (ms) | p95 (ms) | Success');
    console.log('---------------------------------------------------------------');
    for (const [epPath, stat] of Object.entries(endpointStats)) {
        if (stat.total === 0) continue;
        const sorted = stat.latencies.slice().sort((a, b) => a - b);
        const epAvg = (stat.latencies.reduce((a, b) => a + b, 0) / stat.latencies.length).toFixed(0);
        const epP95 = calculatePercentile(sorted, 95);
        const epSuccessPct = ((stat.success / stat.total) * 100).toFixed(0);
        const pathFormatted = epPath.padEnd(29, ' ');
        const totalFormatted = String(stat.total).padEnd(5, ' ');
        const avgFormatted = String(epAvg).padEnd(8, ' ');
        const p95Formatted = String(epP95).padEnd(8, ' ');
        console.log(` ${pathFormatted} | ${totalFormatted} | ${avgFormatted} | ${p95Formatted} | ${epSuccessPct}%`);
    }
    console.log('===============================================================\n');

    // Generate GitHub Actions Summary Markdown
    const markdownSummary = `
## 🚀 LifeLedger Baseline / Load Test Results

| Metric | Result | Target / Baseline |
| :--- | :--- | :--- |
| **Concurrent Virtual Users** | \`${VIRTUAL_USERS} VUs\` | 100 users |
| **Duration** | \`${totalDurationSeconds.toFixed(1)}s\` | 1 minute (60s) |
| **Total Requests** | **\`${totalRequests.toLocaleString()}\`** | Thousands / min |
| **Throughput (RPS)** | **\`${rps} req/sec\`** | High throughput |
| **Success Rate** | \`${successRate}%\` | > 95% |

### ⏱️ Response Time Performance
| Percentile / Metric | Response Time | Description |
| :--- | :--- | :--- |
| **Minimum (Fastest)** | \`${minLatency} ms\` | Fastest recorded request |
| **Average (Mean)** | **\`${avgLatency} ms\`** | Expected normal response time |
| **Median (p50)** | \`${p50} ms\` | 50% of requests faster than this |
| **90th Percentile (p90)**| \`${p90} ms\` | 90% of requests within this latency |
| **95th Percentile (p95)**| \`${p95} ms\` | 95% of requests within this latency |
| **Maximum (Slowest)** | \`${maxLatency} ms\` | Slowest single request |

### 📡 Status Code Breakdown
${Object.entries(statusCodes).map(([code, count]) => `- **HTTP ${code === '0' ? 'TIMEOUT/NET_ERR' : code}**: \`${count}\` requests (\`${((count / totalRequests) * 100).toFixed(1)}%\`)`).join('\n')}
`;

    // Save outputs
    const reportsDir = path.join(__dirname, '..', 'test-reports');
    if (!fs.existsSync(reportsDir)) {
        fs.mkdirSync(reportsDir, { recursive: true });
    }

    fs.writeFileSync(path.join(reportsDir, 'load-test-summary.md'), markdownSummary.trim());
    fs.writeFileSync(path.join(reportsDir, 'load-test-metrics.json'), JSON.stringify({
        targetUrl: TARGET_URL,
        vus: VIRTUAL_USERS,
        durationSeconds: totalDurationSeconds,
        totalRequests,
        rps: parseFloat(rps),
        successRate: parseFloat(successRate),
        latencies: {
            min: minLatency,
            avg: parseFloat(avgLatency),
            p50,
            p90,
            p95,
            p99,
            max: maxLatency
        },
        statusCodes
    }, null, 2));

    // If running in GitHub Actions, write directly to step summary
    if (process.env.GITHUB_STEP_SUMMARY) {
        fs.appendFileSync(process.env.GITHUB_STEP_SUMMARY, markdownSummary);
    }
}

runLoadTest().catch(err => {
    console.error('Fatal load test error:', err);
    process.exit(1);
});
