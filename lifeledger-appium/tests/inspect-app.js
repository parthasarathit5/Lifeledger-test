const { remote } = require("webdriverio");

(async () => {
    const driver = await remote({
        hostname: "127.0.0.1",
        port: 4723,
        path: "/",
        logLevel: "error",
        capabilities: {
            platformName: "Android",
            "appium:deviceName": "TGYPUWBYCANF6L9T",
            "appium:automationName": "UiAutomator2",
            "appium:appPackage": "com.example.lifeledger_app",
            "appium:appActivity": ".MainActivity",
            "appium:noReset": true
        }
    });

    await driver.pause(3000);

    console.log("PACKAGE:", await driver.getCurrentPackage());
    console.log("PAGE SOURCE:");
    console.log(await driver.getPageSource());

    await driver.deleteSession();
})().catch(err => {
    console.error(err);
    process.exit(1);
});
