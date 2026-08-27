const {Builder} = require("selenium-webdriver");
const chrome = require("selenium-webdriver/chrome");

(async () => {
    const options = new chrome.Options();
    options.addArguments("--window-size=1440,1000");

    const driver = await new Builder()
        .forBrowser("chrome")
        .setChromeOptions(options)
        .build();

    try {
        await driver.get(process.env.BASE_URL || "http://localhost:56555/");
        await driver.sleep(8000);

        console.log("URL:", await driver.getCurrentUrl());
        console.log("TITLE:", await driver.getTitle());
        console.log("SOURCE LENGTH:", (await driver.getPageSource()).length);

        const source = await driver.getPageSource();
        console.log("HAS FLUTTER:", source.includes("flutter"));
        console.log("HAS LIFELEDGER:", source.includes("LifeLedger"));

        console.log("BODY TEXT:");
        console.log(await driver.findElement({css: "body"}).getText());

    } finally {
        await driver.quit();
    }
})();
