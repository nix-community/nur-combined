{ lib
, fetchFromGitHub
, stdenv
, python3
, wayland
}:

stdenv.mkDerivation rec {
  pname = "wayland-debug";
  version = "0-unstable-2026-05-22";

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "wayland-debug";
    rev = "110592ab1e6299281da7eab47419843ac0861023";
    hash = "sha256-zTZ9tUS8tq66dav0R8pKEvqIkl4GhFqnOP0uM/u+exg=";
  };

  postPatch = ''
    patchShebangs *
    substituteInPlace main.py \
      --replace-fail '/usr/bin/python3' '${python3.interpreter}'
    rm -f resources/protocols/core/git-blame-ignore-revs
  '';

  installPhase = ''
    mkdir -p $out/lib/dist
    mv * $out/lib/dist
    mkdir -p $out/bin
    ln -s $out/lib/dist/main.py $out/bin/wayland-debug
    mkdir -p $out/lib/dist/resources/wayland/build/src
    ln -s ${wayland}/lib/* $out/lib/dist/resources/wayland/build/src/
  '';

  meta = {
    description = "Command line tool to help debug Wayland clients and servers";
    homepage = "https://github.com/wmww/wayland-debug";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    mainProgram = "wayland-debug";
  };
}

