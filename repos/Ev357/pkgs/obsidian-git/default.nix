{
  stdenv,
  lib,
  pkgs,
  ...
}:
stdenv.mkDerivation rec {
  pname = "obsidian-git";
  version = "2.34.0";

  src = pkgs.fetchFromGitHub {
    owner = "Vinzent03";
    repo = "obsidian-git";
    rev = version;
    sha256 = "sha256-VSJil4Fv5g/UnosEsqVgU88a1jDXMg9UrYjomYa73Wo=";
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
      cp main.js manifest.json styles.css $out/
    '';

  pnpmDeps = pkgs.pnpm.fetchDeps {
    fetcherVersion = 2;
    inherit pname version src;
    hash = "sha256-D4Luh9iOcmRVGBsF3F9r5UtaTOCFSYzO70z8B0PA5YE=";
  };

  meta = {
    description = "Integrate Git version control with automatic backup and other advanced features.";
    homepage = "https://github.com/Vinzent03/obsidian-git";
    changelog = "https://github.com/Vinzent03/obsidian-git/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
