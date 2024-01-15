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
  version = "unstable-2024-01-15";
  outputs = ["out" "man"];
  src = fetchFromSourcehut {
    owner = "~bptato";
    repo = "chawan";
    rev = "f637588d76627368bf7d82f6aa8f5596fe53bddf";
    hash = "sha256-sfbDC6tcvmo2p5QX2REY9jrOUeoVKhpfJmiSlthBLgE=";
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

  makeFlags = [
    "PREFIX=${builtins.placeholder "out"}"
  ];

  enableParallelBuilding = true;

  postBuild = ''
    make manpage
  '';

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
