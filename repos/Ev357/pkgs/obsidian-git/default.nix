{
  stdenv,
  lib,
  pkgs,
  ...
}:
stdenv.mkDerivation rec {
  pname = "obsidian-git";
  version = "2.41.1";

  src = pkgs.fetchFromGitHub {
    owner = "Vinzent03";
    repo = "obsidian-git";
    rev = version;
    sha256 = "sha256-Jdz+EOsifwogOxxilV2cLpYkvIkuDGYgzWA8KMkgkSI=";
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
      cp main.js manifest.json styles.css $out/
    '';

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  pnpmDeps = pkgs.fetchPnpmDeps {
    fetcherVersion = 4;
    inherit pname version src;
    hash = "sha256-pDeDnuZw3mLPuAW6UEfT2Q2aWmldCMUIbLeeoITjCjw=";
  };

  meta = {
    description = "Integrate Git version control with automatic backup and other advanced features.";
    homepage = "https://github.com/Vinzent03/obsidian-git";
    changelog = "https://github.com/Vinzent03/obsidian-git/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
