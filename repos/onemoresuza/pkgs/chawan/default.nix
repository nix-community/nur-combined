{
  curl,
  fetchFromSourcehut,
  lib,
  nim2,
  pkg-config,
  stdenv,
  zlib,
}:
stdenv.mkDerivation rec {
  pname = "chawan";
  version = "unstable-2023-09-17";
  src = fetchFromSourcehut {
    owner = "~bptato";
    repo = pname;
    rev = "ba2d0b1d8dae67b6f8d3e815a61d26c7c0b1ce2f";
    hash = "sha256-J7EL58kAAMlJl7i7xq9yVNjk/ySH77/E7PzIm4fdo4w=";
    domain = "sr.ht";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    nim2
  ];

  buildInputs = [zlib] ++ (with curl; [out dev]);

  buildPhase = ''
    make release
  '';

  installFlags = [
    "prefix=${placeholder "out"}"
  ];

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
