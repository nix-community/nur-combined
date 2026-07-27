{ lib
, stdenv
, fetchurl
, autoPatchelfHook
}:

let
  version = "0.20.20";

  # Map nix system to the OS/arch used in GitHub release filenames
  releaseName = {
    "x86_64-darwin" = "darwin_amd64";
    "aarch64-darwin" = "darwin_arm64";
    "x86_64-linux" = "linux_amd64";
    "aarch64-linux" = "linux_arm64";
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  sha256 = {
    "darwin_amd64" = "a0b8576ecd8d5ed247bdaaa18b0ad59c93ec23aae2cce7dc78f5b66a3f07aa88";
    "darwin_arm64" = "15dcd45061d270b7569df11a04895139e60e3ad9ba93aa46dcdd3fc222fb33c3";
    "linux_amd64" = "2224082c20f36a4830257856c3934dab47e81d18d575d0a02b0d6448216b2c32";
    "linux_arm64" = "036f5c65e603a68d6eae331c7f5b1db2f5931ec0a53913dc51ab52d2de90be84";
  }.${releaseName};
in

stdenv.mkDerivation {
  pname = "skillshare";
  inherit version;

  src = fetchurl {
    url = "https://github.com/runkids/skillshare/releases/download/v${version}/skillshare_${version}_${releaseName}.tar.gz";
    inherit sha256;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  sourceRoot = ".";

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -Dm755 skillshare $out/bin/skillshare
  '';

  meta = with lib; {
    description = "A command-line tool for skillshare";
    mainProgram = "skillshare";
    homepage = "https://github.com/runkids/skillshare";
    license = licenses.mit;
    platforms = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];
  };
}
