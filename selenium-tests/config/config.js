module.exports = {
    baseUrl: process.env.BASE_URL || "http://localhost:5000",
    browser: process.env.BROWSER || "chrome",
    headless: process.env.HEADLESS !== "false"
};
