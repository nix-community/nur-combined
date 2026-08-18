{ lib
, fetchFromCodeberg
, stdenv
, libX11
, libXScrnSaver
, systemdLibs
}:

let
  pname = "autolock";
  version = "0.5";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromCodeberg {
    owner = "ayari";
    repo = "autolock";
    rev = version;
    hash = "sha256-wMjAeJIXPmns2xlyp3JfJG4Tk7/5K2b9dnSdRjcyCwQ=";
  };

  patches = [
    ./systemd-libs.patch
  ];

  buildInputs = [
    libX11
    libXScrnSaver
    systemdLibs
  ];

  installPhase = ''
    install -Dm755 autolock $out/bin/autolock
    install -Dm644 autolock.1 $out/share/man/man1/autolock.1
    install -Dm644 LICENSE $out/share/licenses/${pname}/LICENSE
    install -Dm644 README.md $out/share/doc/${pname}/README.md
  '';

  meta = {
    description = "A minimal X11 idle-watcher";
    homepage = "https://codeberg.org/ayari/autolock";
    license = lib.licenses.cc0;
    mainProgram = "autolock";
    # maintainers = with lib.maintainers; [ anas ];
    platforms = lib.platforms.unix;
  };
}
