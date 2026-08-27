const {Builder, By, until} = require("selenium-webdriver");
const chrome = require("selenium-webdriver/chrome");
const assert = require("assert");

const BASE_URL = process.env.BASE_URL || "http://localhost:56555/";

describe("LifeLedger Authentication E2E", function () {
    this.timeout(120000);

    let driver;

    beforeEach(async function () {
        const options = new chrome.Options();
        if (process.env.HEADLESS !== "false") {
            options.addArguments("--headless=new");
        }
        options.addArguments("--window-size=1440,1000");

        driver = await new Builder()
            .forBrowser("chrome")
            .setChromeOptions(options)
            .build();

        await driver.get(BASE_URL);
        await driver.sleep(3000);
    });

    afterEach(async function () {
        if (driver) await driver.quit();
    });

    it("SEL-001 - Login page loads", async function () {
        const body = await driver.findElement(By.css("body"));
        const text = await body.getText();

        assert.ok(text.includes("LifeLedger"));
        assert.ok(text.includes("Welcome back"));
    });

    it("SEL-002 - Login page contains email field", async function () {
        const email = await driver.findElement(
            By.css('input[type="email"]')
        );
        assert.ok(await email.isDisplayed());
    });

    it("SEL-003 - Login page contains password field", async function () {
        const password = await driver.findElement(
            By.css('input[type="password"]')
        );
        assert.ok(await password.isDisplayed());
    });

    it("SEL-004 - Empty login shows validation", async function () {
        const buttons = await driver.findElements(
            By.xpath("//*[contains(text(),'Sign In')]")
        );

        assert.ok(buttons.length > 0);
        await buttons[0].click();

        await driver.sleep(500);

        const body = await driver.findElement(By.css("body"));
        const text = await body.getText();

        assert.ok(text.includes("Please fill in all fields"));
    });

    it("SEL-005 - Create one navigates to signup", async function () {
        const createOne = await driver.findElement(
            By.xpath("//*[contains(text(),'Create one')]")
        );

        await createOne.click();
        await driver.sleep(1000);

        const body = await driver.findElement(By.css("body"));
        const text = await body.getText();

        assert.ok(text.includes("Create account"));
    });

    it("SEL-006 - Signup page contains full name", async function () {
        const createOne = await driver.findElement(
            By.xpath("//*[contains(text(),'Create one')]")
        );

        await createOne.click();
        await driver.sleep(1000);

        const body = await driver.findElement(By.css("body"));
        const text = await body.getText();

        assert.ok(text.includes("FULL NAME"));
    });

    it("SEL-007 - Signup page contains email", async function () {
        const createOne = await driver.findElement(
            By.xpath("//*[contains(text(),'Create one')]")
        );

        await createOne.click();
        await driver.sleep(1000);

        const emails = await driver.findElements(
            By.css('input[type="email"]')
        );

        assert.ok(emails.length > 0);
    });

    it("SEL-008 - Signup empty form validation", async function () {
        const createOne = await driver.findElement(
            By.xpath("//*[contains(text(),'Create one')]")
        );

        await createOne.click();
        await driver.sleep(1000);

        const button = await driver.findElement(
            By.xpath("//*[contains(text(),'Create Account')]")
        );

        await button.click();
        await driver.sleep(500);

        const body = await driver.findElement(By.css("body"));
        const text = await body.getText();

        assert.ok(text.includes("Please fill in all fields"));
    });
});
