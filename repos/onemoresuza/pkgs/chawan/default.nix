{
  curl,
  fetchFromSourcehut,
  lib,
  nim2,
  pkg-config,
  stdenv,
  zlib,
  pandoc,
  writeScript,
}:
stdenv.mkDerivation {
  pname = "chawan";
  version = "unstable-2023-11-01";
  src = fetchFromSourcehut {
    owner = "~bptato";
    repo = "chawan";
    rev = "cc02a6c30af164f087e07f546f4177d0b9cf3bcb";
    hash = "sha256-QxlPnNOlaQcgLpyFOQW5WC2v4Lxn7nT8xTiFmaS5vmU=";
    domain = "sr.ht";
    fetchSubmodules = true;
  };

  enableParallelBuilding = true;

  nativeBuildInputs = [
    pkg-config
    nim2
    pandoc
  ];

  buildInputs = [zlib] ++ (with curl; [out dev]);

  buildPhase = ''
    runHook preBuild
    make -j"$NIX_BUILD_CORES" release
    runHook postBuild
  '';

  preInstall = ''
    make manpage
  '';

  makeFlags = [
    "prefix=${builtins.placeholder "out"}"
    "manprefix=${builtins.placeholder "out"}/share/man"
  ];

  passthru.updateScript = writeScript "update-chawan" ''
    #!/usr/bin/env nix-shell
    #!nix-shell -i bash -p nix-prefetch-git jq common-updater-scripts coreutils

    set -euo pipefail

    info="$(
    	nix-prefetch-git --fetch-submodules --no-deepClone --branch-name master https://git.sr.ht/~bptato/chawan |
    		jq -r '(."date" | split("T"))[0], ."hash", ."rev"' |
    		tr '\n' ' '
    )"

    read -r date hash rev <<<$info

    update-source-version chawan "unstable-$date" "$hash" --rev="$rev"
  '';

  meta = with lib; {
    description = "A text-mode web browser";
    longDescription = ''
      A text-mode web browser. It displays websites in your terminal and allows you to navigate on them.
      It can also be used as a terminal pager.
    '';
    homepage = "https://sr.ht/~bptato/chawan/";
    license = licenses.unlicense;
    mainProgram = "cha";
  };
}
