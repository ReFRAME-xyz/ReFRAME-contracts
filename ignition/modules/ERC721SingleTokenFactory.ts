import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC721SingleTokenFactory", (m) => {
  const factory = m.contract("ERC721SingleTokenFactory");

  return { factory };
});