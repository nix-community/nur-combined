{ lib, pkgs, python3Packages, ... }:

with python3Packages; buildPythonApplication rec {
  name = "Fluffy-${version}";
  format = "other";
  version = "2.7";

  src = pkgs.fetchFromGitHub {
    owner = "fourminute";
    repo = "Fluffy";
    rev = "v${version}";
    sha256 = "1l346bklidcl40q91cfdszrfskdwlmfjbmsc3mgs0i8wi1yhvq99";
  };

  prePatch = ''
    sed -e "s|/tmp|$HOME/.config/fluffy|" -i linux/fluffy.desktop
  '';

  installPhase = ''
    env
    install -Dm 644 linux/80-fluffy-switch.rules "$out/etc/udev/rules.d/80-fluffy-switch.rules"
    install -Dm 644 linux/fluffy.desktop "$out/usr/share/applications/fluffy.desktop"
    install -Dm 644 icons/16x16/fluffy.png "$out/share/icons/hicolor/16x16/apps/fluffy.png"
    install -Dm 644 icons/24x24/fluffy.png "$out/share/icons/hicolor/24x24/apps/fluffy.png"
    install -Dm 644 icons/32x32/fluffy.png "$out/share/icons/hicolor/32x32/apps/fluffy.png"
    install -Dm 644 icons/48x48/fluffy.png "$out/share/icons/hicolor/48x48/apps/fluffy.png"
    install -Dm 644 icons/64x64/fluffy.png "$out/share/icons/hicolor/64x64/apps/fluffy.png"
    install -Dm 644 icons/128x128/fluffy.png "$out/share/icons/hicolor/128x128/apps/fluffy.png"
    install -Dm 755 fluffy.pyw "$out/bin/fluffy"
    wrapProgram  "$out/bin/fluffy" --set PYTHONPATH "$PYTHONPATH"
  '';

  propagatedBuildInputs = [
    pyqt5 pyusb  libusb1 configparser tkinter
  ];

  meta = {
    homepage = https://github.com/fourminute/Fluffy;
    description = "A feature-rich tool for installing NSPs";
    license = lib.licenses.gpl3;
  };
}
