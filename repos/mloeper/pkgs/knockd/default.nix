{ stdenv
, fetchzip
, lib
, libpcap
, autoreconfHook
}:
stdenv.mkDerivation
rec {
  name = "knockd";
  version = "0.8";

  src = fetchzip {
    url = "https://github.com/jvinet/knock/archive/refs/tags/v${version}.zip";
    sha256 = "sha256-GOg6wovyr6J5qHm5EsOxrposFtwwx/FyJs7g0dagFmk=";
  };

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    libpcap
  ];

  configurePhase = ''
    aclocal
    autoconf
    ./configure
  '';

  installPhase = ''
    runHook postInstall

    # we install the client only; feel free to include the daemon and the systemd service
    # see also: https://gitlab.archlinux.org/archlinux/packaging/packages/knockd/-/blob/main/PKGBUILD?ref_type=heads

    install -d $out/bin
    install -m755 knock $out/bin
  '';

  meta = with lib; {
    homepage = "http://www.zeroflux.org/projects/knock";
    description = "A simple port-knocking daemon";
    platforms = [ "x86_64-linux" ];
    mainProgram = "knock";
  };
}
