{ lib, stdenv, pins
, unzip
}:
stdenv.mkDerivation {
  pname = "arcconf";
  version = "v2.05.22932";

  src = pins.arcconf.outPath;

  nativeBuildInputs = [
    unzip
  ];

  unpackCmd = ''unzip -qq "$curSrc"'';

  sourceRoot = "linux_x64";

  installPhase = ''
    install -m755 -D static_arcconf/cmdline/arcconf $out/bin/arcconf
  '';

  dontPatchELF = true;
  dontStrip = true;

  meta = with lib; {
    description = "Microsemi Adaptec ARCCONF command line interface utility";
    homepage    = https://storage.microsemi.com/en-us/speed/raid/storage_manager/arcconf_v2_05_22932_zip.php;
    maintainers = with maintainers; [ arobyn ];
    platforms   = [ "x86_64-linux" ];
    license     = {
      fullName = "Microsemi License for arcconf_v2_05_22932.zip";
      url = "https://storage.microsemi.com/en-us/support/_eula/license.php?arcconf_v2_05_22932.zip";
      free = false;
    };
  };
}
