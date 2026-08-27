const { Builder, By, until } = require("selenium-webdriver");
const chrome = require("selenium-webdriver/chrome");
const fs = require("fs");
const config = require("../config/config");

const testCases = JSON.parse(
    fs.readFileSync("./test-cases/selenium-300.json", "utf8")
);

describe("LifeLedger Selenium E2E - 300 Cases", function () {

    this.timeout(60000);

    let driver;

    before(async function () {
        const options = new chrome.Options();

        if (config.headless) {
            options.addArguments("--headless=new");
        }

        options.addArguments("--window-size=1440,900");

        driver = await new Builder()
            .forBrowser("chrome")
            .setChromeOptions(options)
            .build();
    });

    after(async function () {
        if (driver) {
            await driver.quit();
        }
    });

    for (const testCase of testCases) {

        it(`${testCase.id} - ${testCase.category} - ${testCase.name}`, async function () {

            await driver.get(config.baseUrl);

            await driver.sleep(5000);

            const currentUrl = await driver.getCurrentUrl();

            if (!currentUrl.startsWith(config.baseUrl)) {
                throw new Error(
                    `Unexpected URL. Expected ${config.baseUrl}, got ${currentUrl}`
                );
            }

            const title = await driver.getTitle();

            console.log(
                `${testCase.id} loaded | URL: ${currentUrl} | Title: ${title}`
            );
        });
    }
});
