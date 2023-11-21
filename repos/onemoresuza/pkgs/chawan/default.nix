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
  version = "unstable-2023-11-21";
  src = fetchFromSourcehut {
    owner = "~bptato";
    repo = "chawan";
    rev = "7762995c3e153a4ddc99c51167df05f57ea7f463";
    hash = "sha256-Ad2+whCPaCJV2pbeQ4jeCYlYjFRfsk302y6l7SmeQAY=";
    domain = "sr.ht";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    nim2
    pandoc
  ];

  buildInputs = [
    zlib
    curl
  ];

  buildFlags = [
    "release"
    "manpage"
  ];

  makeFlags = [
    "prefix=${builtins.placeholder "out"}"
    "manprefix=${builtins.placeholder "out"}/share/man"
  ];

  enableParallelBuilding = true;

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
