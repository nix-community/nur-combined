{ name, lib, pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "obsidian.plugins.${name}";
  version = "2.0.0-beta.2";
  repo = "https://github.com/liamcain/obsidian-calendar-plugin";

  src = pkgs.fetchFromGitHub {
    owner = "liamcain";
    repo = "obsidian-calendar-plugin";
    rev = version;
    hash = "sha256-KCZTgSxLLrRUVpM3t5qmxlsdrYifSQ0u3sq10y7Qf2s=";
  };

  offlineCache = pkgs.fetchYarnDeps {
    yarnLock = src + "/yarn.lock";
    hash = "sha256-ad+yZO5SvlRo1Xg9DJafmbsY54GJCk8jTDKBAF7QXuo=";
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

  meta = with lib; {
    homepage = repo;
    changelog = "${repo}/releases/tag/${version}";
    description = "Simple calendar widget for Obsidian. ";
    license = licenses.mit;
  };
}
