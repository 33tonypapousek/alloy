import baseCode from '../../../../src/baseCode/index';

let instanceNames: string[] = [];

describe("baseCode", () => {
  beforeEach(() => {
    instanceNames = ["alloy", "bill", "ted"]
  });
  it("should be instantiated with instanceNames", async () => {
    await baseCode(window, instanceNames);
    expect(Object.keys(window)).toContain(instanceNames[0]); // window.alloy
    expect(Object.keys(window)).toContain(instanceNames[1]); // window.bill
    expect(Object.keys(window)).toContain(instanceNames[2]); // window.ted
    expect(window[instanceNames[0]].q).toBeTruthy; // window.alloy.q
    expect(window[instanceNames[1]].q).toBeTruthy; // window.bill.q
    expect(window[instanceNames[2]].q).toBeTruthy; // window.ted.q
    return;
  });
});