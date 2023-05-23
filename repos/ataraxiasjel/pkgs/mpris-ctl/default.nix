{ stdenv
, lib
, fetchFromGitHub
, installShellFiles
, pkg-config
, scdoc
, dbus
}:

stdenv.mkDerivation rec {
  pname = "mpris-ctl";
  version = "0.8.5";

  src = fetchFromGitHub {
    owner = "mariusor";
    repo = "mpris-ctl";
    rev = "v${version}";
    hash = "sha256-b0BWBZn5XdXM2L3Q1LZd/QV5edlC/bx11MkRgJQZoAA=";
  };

  nativeBuildInputs = [ pkg-config scdoc installShellFiles ];

  buildInputs = [ dbus ];

  buildPhase = ''
    runHook preBuild

    make VERSION="${version}" release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    scdoc < mpris-ctl.1.scd > mpris-ctl.1
    installManPage mpris-ctl.1
    install -D mpris-ctl $out/bin/mpris-ctl

    runHook postInstall
  '';

  meta = with lib; {
    description = "Basic mpris player control for linux command line";
    homepage = "https://github.com/mariusor/mpris-ctl";
    platforms = platforms.linux;
    license = licenses.mit;
    maintainers = with maintainers; [ ataraxiasjel ];
  };
}
