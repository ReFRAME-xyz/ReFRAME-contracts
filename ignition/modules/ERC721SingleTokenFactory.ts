import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC721SingleTokenFactoryV1", (m) => {
  const factory = m.contract("ERC721SingleTokenFactory");

  return { factory };
});