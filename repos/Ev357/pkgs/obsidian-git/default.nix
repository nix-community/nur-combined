{
  stdenv,
  lib,
  pkgs,
  ...
}:
stdenv.mkDerivation rec {
  pname = "obsidian-git";
  version = "2.38.3";

  src = pkgs.fetchFromGitHub {
    owner = "Vinzent03";
    repo = "obsidian-git";
    rev = version;
    sha256 = "sha256-LcFIpQHOLjCY4L2vCYBjBN/73Bfg5Wa+tXoVmcBMrbY=";
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

  pnpmDeps = pkgs.fetchPnpmDeps {
    fetcherVersion = 3;
    inherit pname version src;
    hash = "sha256-h1SZZF3GZaNniXptxzKeqP8ROvd17bBTjZQ9CHna5HY=";
  };

  meta = {
    description = "Integrate Git version control with automatic backup and other advanced features.";
    homepage = "https://github.com/Vinzent03/obsidian-git";
    changelog = "https://github.com/Vinzent03/obsidian-git/releases/tag/${version}";
    license = lib.licenses.mit;
  };
}
