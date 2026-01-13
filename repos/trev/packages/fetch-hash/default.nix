{
  pkgs,
  runtimeShell,
  lib,
  nix,
  wget,
  mktemp,
  shellcheck-minimal,
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  name = "fetch-hash";
  src = ./fetch-hash.sh;

  nativeBuildInputs = [
    shellcheck-minimal
  ];

  runtimeInputs = [
    nix
    wget
    mktemp
  ];

  dontBuild = true;

  unpackPhase = ''
    cp "$src" fetch-hash.sh
  '';

  configurePhase = ''
    echo "#!${runtimeShell}" >> fetch-hash
    echo 'export PATH="${lib.makeBinPath finalAttrs.runtimeInputs}:$PATH"' >> fetch-hash
    tail -n +2 fetch-hash.sh >> fetch-hash
    chmod +x fetch-hash
  '';

  doCheck = true;
  checkPhase = ''
    shellcheck ./fetch-hash
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp fetch-hash $out/bin/fetch-hash
  '';

  meta = {
    description = "Fetch the hashes of remote files";
    mainProgram = "fetch-hash";
    homepage = "https://github.com/spotdemo4/nur/tree/main/pkgs/fetch-hash/fetch-hash.sh";
    platforms = lib.platforms.all;
  };
})
