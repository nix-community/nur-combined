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
    rev = "05521565af890337c0e20725840fab88d033913c";
    hash = "sha256-PHgFVntRHlYyBMtxXFC1BliX7jyOMkZOLreL5aupapA=";
  };

  npmDepsHash = "sha256-ZFoCnpEoJxCRVCi7uUYXlGVTiWBAXk3rR/i7+EGVfvM=";

  meta = {
    broken = false;
    description =
      "Visual Studio Code language support extension for Solidity smart contracts in Ethereum";
    homepage = "https://github.com/juanfranblanco/vscode-solidity";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.mit;
  };
}
