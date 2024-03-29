{ stdenv, lib, fetchurl, unzip, runtimeShell, jre }:

stdenv.mkDerivation {
  name = "avr8-burn-omat-2.1.2";

  src = fetchurl {
    url = http://avr8-burn-o-mat.aaabbb.de/AVR8_Burn-O-Mat_2_1_2.zip;
    sha256 = "02k0fd0cd3y1yqip36wr3bkxbywp8913w4y7jdg6qwqxjnii58ln";
  };

  buildInputs = [ unzip ];

  phases = "unpackPhase installPhase";

  # move to nix-support to not create that many symlinks..
  # TODO burnomat tries to read /usr/local/etc/avrdude.conf (but you can edit it within the settings dialog)
  installPhase = ''
    mkdir -p $out/{nix-support,bin}
    mv *.jar license_gpl-3.0.txt lib *.xml *.png $out/nix-support
    cat >> $out/bin/avr8-burn-omat << EOF
    #!${runtimeShell}
    cd $out/nix-support; exec ${jre}/bin/java -jar AVR8_Burn_O_Mat.jar
    EOF
    chmod +x $out/bin/avr8-burn-omat
  '';

  meta = with lib; {
    description = "GUI tool for avrdude";
    homepage = http://avr8-burn-o-mat.aaabbb.de/avr8_burn_o_mat_avrdude_gui_en.html;
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
