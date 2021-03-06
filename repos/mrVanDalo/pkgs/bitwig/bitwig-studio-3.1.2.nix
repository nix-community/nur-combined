{ stdenv, fetchurl, bitwig-studio2, xorg, ... }:

bitwig-studio2.overrideAttrs (oldAttrs: rec {
  name = "bitwig-studio-${version}";
  version = "3.1.2";

  src = fetchurl {
    url =
      "https://downloads.bitwig.com/stable/${version}/bitwig-studio-${version}.deb";
    sha256 = "07djn52lz43ls6fa4k1ncz3m1nc5zv2j93hwyavnr66r0hlqy7l9";
  };

  buildInputs = bitwig-studio2.buildInputs ++ [ xorg.libXtst ];

  installPhase = ''
    ${oldAttrs.installPhase}

    # recover commercial jre
    rm -f $out/libexec/lib/jre
    cp -r opt/bitwig-studio/lib/jre $out/libexec/lib
  '';

})
