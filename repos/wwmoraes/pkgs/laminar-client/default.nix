{
  capnproto,
  cmake,
  fetchFromGitHub,
  lib,
  pandoc,
  stdenv,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "laminar-client";
  version = "1.3";

  outputs = [
    "out"
    "doc"
  ];

  src = fetchFromGitHub {
    owner = "ohwgiles";
    repo = "laminar";
    tag = finalAttrs.version;
    hash = "sha256-eo5WzvmjBEe0LAfZdQ/U0XepEE2kdWKKiyE4HOi3RXk=";
  };

  patches = [
    ./patches/capnp-no-standard-import.patch
    ./patches/client-only.patch
  ];

  nativeBuildInputs = [
    capnproto
    cmake
    pandoc
  ];

  buildInputs = [
    capnproto
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LAMINAR_VERSION" finalAttrs.version)
    (lib.cmakeFeature "CMAKE_BUILD_TYPE" "Release")
  ];

  postInstall = ''
    mv $out/usr/share/* $out/share/
    rmdir $out/usr/share $out/usr

    mkdir -p $out/share/doc/laminar
    pandoc -s ../UserManual.md -o $out/share/doc/laminar/UserManual.html
  '';

  meta = {
    description = "Lightweight and modular continuous integration service (client only)";
    homepage = "https://laminar.ohwg.net";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
    maintainers = with lib.maintainers; [
      wwmoraes
    ];
  };
})
