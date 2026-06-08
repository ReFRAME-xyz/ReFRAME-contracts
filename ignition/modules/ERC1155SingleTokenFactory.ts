import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC1155SingleTokenFactoryV2", (m) => {
  const factory = m.contract("ERC1155SingleTokenFactory", [
    "https://nft.reframeit.xyz/api/v1/metadata/"
  ]);

  return { factory };
});