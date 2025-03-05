{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  cmake,
  ninja,
}:
stdenv.mkDerivation rec {
  pname = "EmmyLuaCodeStyle";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "CppCXY";
    repo = pname;
    rev = version;
    hash = "sha256-4r3XUMK+X+4fzRxwhQqbtC5Atce4trznFb6VJx4i4y0=";
  };

  nativeBuildInputs = [
    makeWrapper
    cmake
    ninja
  ];

  meta.mainProgram = "CodeFormat";
}
