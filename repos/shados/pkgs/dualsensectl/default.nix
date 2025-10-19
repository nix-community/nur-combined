{
  lib,
  stdenv,
  pins,
  pkg-config,
  dbus,
  hidapi,
}:

stdenv.mkDerivation rec {
  pname = "dualsensectl";
  version = "unstable-git-${pins.dualsensectl.rev}";

  src = pins.dualsensectl.outPath;

  postPatch = ''
    substituteInPlace Makefile \
      --replace "/usr/" "/"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    hidapi
  ];

  installFlags = [ "DESTDIR=$(out)" ];

  meta = with lib; {
    description = "Linux tool for controlling PS5 DualSense controller";
    homepage = "https://github.com/nowrep/dualsensectl";
    maintainers = with maintainers; [ arobyn ];
    license = licenses.gpl2;
  };
}
