{ lib
, fetchFromGitHub
, buildDubPackage
, ldc
, clang
, pkg-config
, openssl
, zlib
, cacert
, libplist
, makeWrapper
}:

buildDubPackage {
  pname = "anisette-v3-server";
  version = "unstable-2026-01-15";

  src = fetchFromGitHub {
    owner = "SZanko";
    repo = "anisette-v3-server";
    rev = "3f96c999330c94141221e31631553ab37d87b725";
    hash = "sha256-+Z5rfLFKTCY2Nb0G9edl/iZsiWIRkS9Ooo6uqJdmQ8A=";
  };

  dubLock = ./dub-lock.json;
  compiler = ldc;
  dubBuildType = "release";


  nativeBuildInputs = [
    ldc
    clang
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openssl
    zlib
    libplist
  ];

  propagatedBuildInputs = [
    cacert
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    install -m755 anisette-v3-server $out/bin/.anisette-v3-server-unwrapped

    makeWrapper $out/bin/.anisette-v3-server-unwrapped $out/bin/anisette-v3-server \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libplist openssl zlib ]}"

    runHook postInstall
  '';


  meta = {
    description = "Sidestore's anisette-v3 compatible server";
    homepage = "https://github.com/SZanko/anisette-v3-server.git";
    license = lib.licenses.unfree; # FIXME: nix-init did not find a license
    mainProgram = "anisette-v3-server";
    maintainers =
      let m = lib.maintainers or {};
      in lib.optionals (m ? szanko) [ m.szanko ];
    platforms = lib.platforms.all;
  };
}
