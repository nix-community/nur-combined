{
  lib,
  stdenv,
  pins,
}:
stdenv.mkDerivation rec {
  pname = "yuescript";
  version = pins.yuescript.rev;

  src = pins.yuescript.outPath;

  preInstall = ''
    mkdir -p $out/bin
  '';

  installFlags = [
    "DESTDIR="
    "INSTALL_PREFIX=$(out)"
  ];

  meta = with lib; {
    homepage = "https://yuescript.org/";
    description = "";
    license = licenses.mit;
    maintainers = with maintainers; [ arobyn ];
  };
}
