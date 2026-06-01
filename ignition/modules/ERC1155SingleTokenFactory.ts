import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC1155SingleTokenFactoryV1", (m) => {
  const factory = m.contract("ERC1155SingleTokenFactory");

  return { factory };
});