{
  lib,
  fetchurl,
  installShellFiles,
  stdenvNoCC,
}:
let
  inherit (stdenvNoCC.hostPlatform) system;
  shaMap = {
    x86_64-linux = "1wbwbzm3ql5py320k5vsggf2h5dd760k4f18g4ppzxrjrppr3gnv";
    aarch64-linux = "0rradhzv61rk17rz6b8kxnyjxkdmwvxamjgsadzz3cvxv7f0fjng";
    x86_64-darwin = "1av7ibi9yqyj46f066fxvcgn6nnkhz3b9sfzsnmckmf0kh9imzyk";
    aarch64-darwin = "0d0lpj159gl0gx3lzh0b4sn0dxhvavk45zaqdqizgp6bnqq0wi7x";
  };

  urlMap = {
    x86_64-linux = "https://github.com/abemedia/stagelint/releases/download/v0.1.7/stagelint-0.1.7-x86_64-unknown-linux-musl.tar.gz";
    aarch64-linux = "https://github.com/abemedia/stagelint/releases/download/v0.1.7/stagelint-0.1.7-aarch64-unknown-linux-musl.tar.gz";
    x86_64-darwin = "https://github.com/abemedia/stagelint/releases/download/v0.1.7/stagelint-0.1.7-x86_64-apple-darwin.tar.gz";
    aarch64-darwin = "https://github.com/abemedia/stagelint/releases/download/v0.1.7/stagelint-0.1.7-aarch64-apple-darwin.tar.gz";
  };
in
stdenvNoCC.mkDerivation {
  pname = "stagelint";
  version = "0.1.7";
  src = fetchurl {
    url = urlMap.${system};
    sha256 = shaMap.${system};
  };

  sourceRoot = ".";

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -vr ./stagelint $out/bin/stagelint
    runHook postInstall
  '';

  meta = {
    description = "Run commands like linters and formatters on staged git files";
    homepage = "https://stagelint.dev";
    license = lib.licenses.mit;
    mainProgram = "stagelint";

    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    platforms = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };
}
