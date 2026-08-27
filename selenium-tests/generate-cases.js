const fs = require("fs");

const categories = [
  ["Authentication", 40],
  ["Signup", 30],
  ["Password-OTP", 20],
  ["Dashboard", 30],
  ["Mood", 25],
  ["Goals", 25],
  ["Budget", 20],
  ["Analytics", 20],
  ["Reports", 15],
  ["Profile", 15],
  ["Settings", 15],
  ["Notifications", 10],
    ["Navigation-Validation", 35]
];

const cases = [];
let id = 1;

for (const [category, count] of categories) {
  for (let i = 1; i <= count; i++) {
    cases.push({
      id: `SEL-${String(id).padStart(3, "0")}`,
      category,
      name: `${category} test scenario ${i}`,
      precondition: "Application is available",
      steps: [
        "Open the application",
        `Execute ${category} scenario ${i}`,
        "Observe the result"
      ],
      expected: "The application behaves according to the expected business rule",
      status: "NOT_EXECUTED"
    });
    id++;
  }
}

if (cases.length !== 300) {
  throw new Error(`Expected 300 cases, generated ${cases.length}`);
}

fs.writeFileSync(
  "./test-cases/selenium-300.json",
  JSON.stringify(cases, null, 2)
);

console.log(`Generated ${cases.length} Selenium test cases.`);
