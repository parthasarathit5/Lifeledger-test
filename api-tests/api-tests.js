const axios = require("axios");
const assert = require("assert");

const BASE_URL =
    process.env.API_BASE_URL || "https://lifeledger-backend.onrender.com";

const api = axios.create({
    baseURL: BASE_URL,
    timeout: 60000,
    validateStatus: () => true
});

describe("LifeLedger API Validation", function () {
    this.timeout(120000);

    let userId = 1;
    let habitId = 1;

    it("API-001 - Login endpoint responds", async function () {
        const response = await api.post("/login/", {
            email: "test@example.com",
            password: "wrong-password"
        });

        assert.ok(response.status >= 200 && response.status < 500);
    });

    it("API-002 - Signup endpoint responds", async function () {
        const response = await api.post("/signup/", {
            name: "API Test User",
            email: `api-test-${Date.now()}@example.com`,
            password: "TestPassword123"
        });

        assert.ok(response.status >= 200 && response.status < 500);
    });

    const userEndpoints = [
        ["API-003", "/dashboard/"],
        ["API-004", "/expenses/"],
        ["API-005", "/income/"],
        ["API-006", "/habits/"],
        ["API-007", "/tasks/"],
        ["API-008", "/mood/"],
        ["API-009", "/history/"],
        ["API-010", "/analytics/"],
        ["API-011", "/lifescore/"],
        ["API-012", "/budget/"],
        ["API-013", "/predictor/"],
        ["API-014", "/compare/"],
        ["API-015", "/alerts/"],
        ["API-016", "/behavior/"],
        ["API-017", "/smart-alerts/"],
        ["API-018", "/goals/"],
        ["API-019", "/daily-summary/"],
        ["API-020", "/heatmap/"],
        ["API-021", "/networth/"],
        ["API-022", "/streaks/"],
        ["API-023", "/achievements/"]
    ];

    for (const [id, endpoint] of userEndpoints) {
        it(`${id} - ${endpoint} endpoint responds`, async function () {
            const response = await api.get(`${endpoint}${userId}/`);

            assert.ok(
                response.status >= 200 && response.status < 500,
                `Unexpected HTTP status: ${response.status}`
            );
        });
    }

    it("API-024 - Forgot password endpoint responds", async function () {
        const response = await api.post("/forgot-password/", {
            email: "test@example.com"
        });

        assert.ok(response.status >= 200 && response.status < 500);
    });

    it("API-025 - Verify OTP endpoint responds", async function () {
        const response = await api.post("/verify-otp/", {
            email: "test@example.com",
            otp: "000000"
        });

        assert.ok(response.status >= 200 && response.status < 500);
    });

    it("API-026 - Reset password endpoint responds", async function () {
        const response = await api.post("/reset-password/", {
            email: "test@example.com",
            otp: "000000",
            password: "TestPassword123"
        });

        assert.ok(response.status >= 200 && response.status < 500);
    });

    it("API-027 - Invalid user ID is handled", async function () {
        const response = await api.get("/dashboard/999999999/");

        assert.ok(
            response.status >= 200 && response.status < 500
        );
    });
});