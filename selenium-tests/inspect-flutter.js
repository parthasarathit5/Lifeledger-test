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

        const elements = await driver.findElements({css: "*"});
        console.log("HTML ELEMENT COUNT:", elements.length);

        for (const el of elements.slice(0, 50)) {
            try {
                const tag = await el.getTagName();
                const role = await el.getAttribute("role");
                const aria = await el.getAttribute("aria-label");
                const text = await el.getAttribute("innerText");

                if (role || aria || text) {
                    console.log({
                        tag,
                        role,
                        aria,
                        text: text ? text.substring(0,100) : ""
                    });
                }
            } catch {}
        }

    } finally {
        await driver.quit();
    }
})();
