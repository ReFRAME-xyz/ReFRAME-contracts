import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC721Factory", (m) => {
  const factory = m.contract("ERC721Factory");

  return { factory };
});