import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("ERC721SingleTokenFactoryV2", (m) => {
  const factory = m.contract("ERC721SingleTokenFactory", [
    "https://nft.reframeit.xyz/api/v1/metadata/"
  ]);

  return { factory };
});