{ lib, buildNpmPackage, fetchFromGitHub, pkg-config, libsecret, }:

buildNpmPackage rec {
  pname = "vscode-solidity-server";
  version = "0.0.165";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libsecret ];

  npmBuildScript = "build:cli";

  makeCacheWritable = true;

  src = fetchFromGitHub {
    owner = "juanfranblanco";
    repo = "vscode-solidity";
    rev = "5097aa915b5a7daee4c997cdb48ec70c2be78a6c";
    hash = "sha256-RzYq7bXo8EDNefHJeXrZbDPpm7jl+2kYdoctrqIGCa4=";
  };

  npmDepsHash = "sha256-ceTB2NDlhqGgvEcQBEKVyUPyoJW28pQj1rIru69C8nM=";

  meta = {
    broken = false;
    description =
      "Visual Studio Code language support extension for Solidity smart contracts in Ethereum";
    homepage = "https://github.com/juanfranblanco/vscode-solidity";

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    license = lib.licenses.mit;
  };
}
