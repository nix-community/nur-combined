{
  stdenv,
  meson,
  ninja,
  fetchFromGitHub,
}:
stdenv.mkDerivation {
  pname = "happly";
  version = "0-unstable-2024-02-06";

  src = fetchFromGitHub {
    owner = "nmwsharp";
    repo = "happly";
    rev = "8a606309daaa680eee495c8279feb0b704148f4a";
    hash = "sha256-KKQdvRxqSXq3Q0TlcpDr+YGlUV3oP7PaE1V2KoP0rXg=";
  };
  patches = [ ./pc.patch ];
  nativeBuildInputs = [
    meson
    ninja
  ];
}
