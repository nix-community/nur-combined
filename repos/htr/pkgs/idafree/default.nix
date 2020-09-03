{ lib
, stdenv
, pkgs
}:


let 
  idafree-installer-package = pkgs.fetchurl {
    url = "https://out7.hex-rays.com/files/idafree70_linux.run";
    sha256 = "0r2dw847zkb2f8gyymmxqnwrzzvxv15kxx4b0b2x30j20j03yqi0";
    executable = true;
  };

  fhsIDAWrapper = pkgs.buildFHSUserEnv rec {
    name = "fhs-ida-wrapper";

    multiPkgs = pkgs: with pkgs; [ zlib libGL gtk3 gtk2 glib cairo pango libdrm gdk-pixbuf freetype dbus fontconfig xorg.libXinerama xorg.libXdamage xorg.libXcursor xorg.libXrender xorg.libXScrnSaver xorg.libXxf86vm xorg.libXi xorg.libSM xorg.libICE xorg.libXt xorg.libXmu xorg.libxcb xorg.libXcomposite xorg.libXtst xorg.libXrandr xorg.libXext xorg.libX11 xorg.libXfixes xorg.xkeyboardconfig libxkbcommon ];

    runScript = pkgs.writeScript "fhs-ida-wrapper" ''
      exec -- "$@"
    '';
  };

in

stdenv.mkDerivation {
  name = "idafree-bin";

  unpackPhase = "true";

  installPhase = ''
      mkdir -p $out/bin $out/opt

      cat <<EOF > $out/bin/idafree
      #!/bin/sh
      cd $out/opt
      exec ${fhsIDAWrapper}/bin/fhs-ida-wrapper ./ida64
      EOF

      chmod +x $out/bin/idafree

      ${fhsIDAWrapper}/bin/fhs-ida-wrapper ${idafree-installer-package} --prefix $out/opt  --mode unattended --installpassword x
  '';
}

