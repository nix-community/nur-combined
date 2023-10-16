{ stdenv, lib, autoPatchelfHook, cups, libusb-compat-0_1, libxml2,
  arch ? stdenv.hostPlatform.system}:
stdenv.mkDerivation {
  pname = "xerox-phaser-3020";
  version = "1.0";

  src = builtins.fetchTarball {
    url =
      "https://download.support.xerox.com/pub/drivers/3020/drivers/linux/en_GB/Xerox_Phaser_3020_LinuxDriver.tar.gz";
    sha256 = "sha256:15xijqw28r0s0zfb8m7klyj7zm4s5l0by1l6caa8gzr4ca89fs4g";
  };

  nativeBuildInputs =
    [ autoPatchelfHook stdenv.cc.cc.lib cups libusb-compat-0_1 libxml2 ];

  installPhase =
    let archdir = lib.removeSuffix "-linux" arch;
    in ''
      mkdir -p $out/lib/cups/filter/
      cp -v $src/${lib.escapeShellArg archdir}/* $out/lib/cups/filter/

      mkdir -p $out/share/cups/model/
      cp -v $src/noarch/share/ppd/Xerox_Phaser_3020.ppd $out/share/cups/model
    '';

  meta = {
    description = "Proprietary Xerox Phaser 3020 CUPS driver";
    homepage = "https://www.xerox.com/";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" "i686-linux" arch ];
  };
}
