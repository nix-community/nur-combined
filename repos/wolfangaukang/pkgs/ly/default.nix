{ stdenv
, lib
, fetchFromGitHub
, substituteAll
, ncurses
, pam
, systemd
, util-linux
, xorg
}:

stdenv.mkDerivation rec {
  pname = "ly";
  # v0.5.3 has issues with one of the submodules
  version = "unstable-2022-05-12";

  src = fetchFromGitHub {
    owner = "fairyglade";
    repo = "ly";
    rev = "78e2fd1a214bae4c19788b2b3a27630ba4b48d8e";
    sha256 = "sha256-c0y093Ie/+Ptj0LYI0r/FDj+A4NLsfxX/OrGU5NCdmg=";
    fetchSubmodules = true;
  };

  buildInputs = [
    ncurses
    pam
    systemd
    util-linux
    xorg.xauth
    xorg.libxcb
    xorg.xorgserver
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-error"
  ];

  makeFlags = [
    "DESTDIR=$out"
  ];

  patches = [
    (substituteAll {
      src = ./0001-NixOS-adaptation.patch;
      utillinux = "${util-linux}";
      systemd = "${systemd}";
      ncurses = "${ncurses}";
      xorgserver = "${xorg.xorgserver}";
      xauth = "${xorg.xauth}";
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/etc/ly

    cat src/main.c

    # We won't be installing pam neither the systemd service.
    # We'd rather rely on creating a module and use
    # security.pam.services and systemd.services.ly.
    cp res/config.ini $out/etc/ly/
    cp res/xsetup.sh $out/etc/ly/
    cp res/wsetup.sh $out/etc/ly/
    cp -r res/lang $out/etc/ly/
    install -Dm555 -t $out/bin bin/ly

    runHook postInstall
  '';

  meta = with lib; {
    description = "TUI display manager";
    license = licenses.wtfpl;
    homepage = "https://github.com/fairyglade/ly";
    maintainers = [ maintainers.vidister ];
    platforms = platforms.linux;
  };
}
