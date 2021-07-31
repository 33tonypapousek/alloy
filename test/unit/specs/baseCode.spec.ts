import 'baseCode';

describe("baseCode", () => {
  it("should be instantiated with 'alloy' instanceName", async () => {
    expect(window.alloy).toBeTruthy; // window.alloy
    expect(window.alloy.q).toBeTruthy; // window.ted.q
    return;
  });
});