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
  version = "unstable-2022-07-24";

  src = fetchFromGitHub {
    owner = "fairyglade";
    repo = "ly";
    rev = "0a798831fe4b7463c28674b8691249604089330d";
    sha256 = "sha256-5vw2cquIxQ5aqbcIwMGBItFrUdbJfYP5R2wlAhF0a7A=";
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
