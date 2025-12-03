{ name, pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "obsidian.plugins.${name}";
  version = "";

  src = pkgs.fetchFromGitHub {
    owner = "";
    repo = "";
    rev = version;
    hash = "";
  };

  offlineCache = pkgs.fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "";
  };

  nativeBuildInputs = with pkgs; [
    nodejs
    yarnConfigHook
    yarnBuildHook
    npmHooks.npmInstallHook
  ];

  installPhase = ''
    mkdir -p $out
    cp ./manifest.json $out/manifest.json
    cp ./main.js $out/main.js
    cp ./styles.css $out/styles.css
  '';

  meta = {
    broken = true;
  };
}
