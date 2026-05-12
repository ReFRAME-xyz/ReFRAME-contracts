import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ReframeMarketplace", (m) => {
  const factory = m.contract("ReframeMarketplace", [
    "0x480eDE04B09e86D8e9Dd5042eDfc270D78B38F35",
    "0x480eDE04B09e86D8e9Dd5042eDfc270D78B38F35",
    1000
  ]);

  return { factory };
});