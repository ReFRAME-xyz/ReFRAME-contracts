import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC1155SingleTokenFactory", (m) => {
  const factory = m.contract("ERC1155SingleTokenFactory");

  return { factory };
});