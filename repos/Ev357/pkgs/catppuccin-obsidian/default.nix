{
  stdenv,
  lib,
  pkgs,
  ...
}:
stdenv.mkDerivation rec {
  pname = "catppuccin-obsidian";
  version = "2.0.4";

  src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "obsidian";
    rev = "065101797eb32eea61ef7b6690e7b9ff7cbf08d9";
    sha256 = "sha256-sN5k263geOtJ1mOCQGM8UdmA/71OhBI5NRwGxJwd80E=";
  };

  nativeBuildInputs = with pkgs; [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  buildPhase =
    # bash
    ''
      runHook preBuild

      pnpm run build

      runHook postBuild
    '';

  installPhase =
    # bash
    ''
      mkdir -p $out/
      cp manifest.json $out/
      cp dist/catppuccin.css $out/theme.css
    '';

  pnpmDeps = pkgs.fetchPnpmDeps {
    fetcherVersion = 3;
    inherit pname version src;
    hash = "sha256-u1hhAw8zOUllUstg1Mfg/czCUIuuR1IiuLr759iSZH0=";
  };

  meta = {
    description = "Catppuccin for Obsidian";
    homepage = "https://github.com/catppuccin/obsidian";
    changelog = "https://github.com/catppuccin/obsidian/releases/tag/v${version}";
    license = lib.licenses.mit;
  };
}
