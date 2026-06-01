import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ReframeMarketplaceV1", (m) => {
  const factory = m.contract("ReframeMarketplace", [
    "0x3895901854b7fC3DFa4a46c52831eFda44beC751",
    "0x3895901854b7fC3DFa4a46c52831eFda44beC751",
    500
  ]);

  return { factory };
});