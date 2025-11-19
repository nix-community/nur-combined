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
    pnpm.configHook
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

  pnpmDeps = pkgs.pnpm.fetchDeps {
    fetcherVersion = 2;
    inherit pname version src;
    hash = "sha256-rPaN7FlYyo1lMTd+9hd6GYov68IHMAO/3YLnL4H2b/0=";
  };

  meta = {
    description = "Catppuccin for Obsidian";
    homepage = "https://github.com/catppuccin/obsidian";
    changelog = "https://github.com/catppuccin/obsidian/releases/tag/v${version}";
    license = lib.licenses.mit;
  };
}
