{
  lib,
  stdenv,
  fetchzip,
  fetchFromGitHub,
  buildFHSEnv,
  writeShellScript,
}:

let
  pname = "asphyxia";
  version = "1.50d";

  platformMap = {
    "x86_64-linux" = "linux-x64";
    "aarch64-linux" = "arm64";
    "armv7l-linux" = "armv7";
  };

  system = stdenv.hostPlatform.system;

  platform = platformMap.${system} or (throw "Unsupported platform: ${system}");

  url = "https://github.com/asphyxia-core/asphyxia-core.github.io/releases/download/v${version}/asphyxia-core-${platform}.zip";

  binaryName = if system == "x86_64-linux" then "asphyxia-core" else "asphyxia-core-${platform}";

  # to get the hash, open nix repl
  # pkgs = import <nixpkgs> {}
  # builtins.readDir (pkgs.fetchzip { url = "https://github.com/asphyxia-core/asphyxia-core.github.io/releases/download/v1.50d/asphyxia-core-arm64.zip"; })
  sha256s = {
    "x86_64-linux" = "sha256-w6Ft8zyuTXU8eW7w1QrzO+O7vaTVe3iqtfKF4uThmlY=";
    "aarch64-linux" = "sha256-DmAxiDYEvv/3k1IxIfnLutENOHHKSk9lz1TkK2cwlSo=";
    "armv7l-linux" = "sha256-GW2EMmGR/xKJhbQ6gFcyyZYj/9WUu2CAZI3FQarlW0M=";
  };

  sha256 = sha256s.${system};

  src = fetchzip {
    inherit url sha256;
    stripRoot = false;
  };

  pluginSrc = fetchFromGitHub {
    owner = "asphyxia-core";
    repo = "plugins";
    # tracing "stable" branch
    rev = "997d141b3ba2ca7eb6806490ab2926cce48863c5";
    sha256 = "sha256-xxhnwIC8Ik0Wq3ccKtxXvYXSNfx5zoianoFDOGfGo1c=";
  };

  enabledPlugins = [
    "bst"
    "ddr"
    "gitadora"
    "iidx"
    "jubeat"
    "mga"
    "museca"
    "nostalgia"
    "popn"
    "popn-hello"
    "sdvx"
  ];

  plugins = stdenv.mkDerivation {
    inherit src pluginSrc;
    name = "asphyxia-plugins";

    installPhase = ''
      mkdir -p $out

      cp $src/plugins/asphyxia-core.d.ts $out/
      cp $src/plugins/package.json $out/
      cp $src/plugins/tsconfig.json $out/
    ''
    + lib.concatMapStringsSep "\n" (p: "cp -r ${pluginSrc}/${p}@asphyxia $out/") enabledPlugins;
  };

  meta = with lib; {
    description = "This is a “e-amuse emulator”";
    homepage = "https://asphyxia-core.github.io/";
    # license = licenses.unfreeRedistributable;
    sourceProvenance = [ sourceTypes.binaryNativeCode ];
    platforms = builtins.attrNames platformMap;
    mainProgram = pname;
  };
in
buildFHSEnv {
  inherit pname version meta;

  runScript = writeShellScript "${pname}-bwrap" ''
    ln --symbolic --force ${src}/${binaryName} ./asphyxia
    ln --symbolic --force --no-target-directory ${plugins} ./plugins
    exec ./asphyxia "$@"
  '';
}
