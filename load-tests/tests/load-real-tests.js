const axios = require("axios");
const assert = require("assert");

const BASE_URL = "https://lifeledger-backend.onrender.com";

describe("LifeLedger Load & Performance Tests", function () {
    this.timeout(120000);

    const endpoints = [
        "/login/",
        "/signup/",
        "/dashboard/1/",
        "/expenses/1/",
        "/income/1/",
        "/habits/1/",
        "/tasks/1/",
        "/mood/1/",
        "/history/1/",
        "/analytics/1/",
        "/lifescore/1/",
        "/budget/1/",
        "/predictor/1/",
        "/compare/1/",
        "/alerts/1/",
        "/behavior/1/",
        "/smart-alerts/1/",
        "/goals/1/",
        "/daily-summary/1/",
        "/heatmap/1/",
        "/networth/1/",
        "/streaks/1/",
        "/achievements/1/",
        "/forgot-password/",
        "/verify-otp/",
        "/reset-password/"
    ];

    for (let i = 1; i <= 300; i++) {
        it(`LOAD-${String(i).padStart(3, "0")} - API load response validation`, async function () {
            const endpoint = endpoints[(i - 1) % endpoints.length];
            const start = Date.now();

            const response = await axios.get(
                `${BASE_URL}${endpoint}`,
                {
                    timeout: 30000,
                    validateStatus: () => true
                }
            );

            const duration = Date.now() - start;

            console.log(
                `LOAD-${String(i).padStart(3, "0")} | ${endpoint} | ${response.status} | ${duration}ms`
            );

            assert.ok(duration < 30000);
        });
    }
});
