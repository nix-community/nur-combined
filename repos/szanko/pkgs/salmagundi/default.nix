{ lib
, stdenv
, clangStdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
}:

clangStdenv.mkDerivation {
  pname = "salmagundi";
  version = "unstable-2025-03-22";

  src = fetchFromGitHub {
    owner = "e-dant";
    repo = "salmagundi";
    rev = "8f78252a7eef1eb0a6278a4b7b0955c155e87aa4";
    hash = "sha256-1C+6xDZ5G5SxHeZmEnWMyT/cZy6gWNcpHmEb1qcOCb0=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  mesonBuildType = "release";

  postPatch = ''
    # der Projekt-autor zieht die tests in einer eigenen subdir ein,
    # wir kappen das einfach
    substituteInPlace meson.build --replace "subdir('tests')" ""
    '';

  configurePhase = ''
    meson setup builddir --prefix=$out --buildtype=release
  '';

  buildPhase = ''
    ninja -C builddir
  '';

  installPhase = ''
    ninja -C builddir install
  '';


  meta = {
    description = "A small, portable, linear probing hash map";
    homepage = "https://github.com/e-dant/salmagundi";
    license = with lib.licenses; [ mit asl20 ];
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
}
