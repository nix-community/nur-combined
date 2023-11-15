{ stdenv
, lib
, fetchurl
}:
stdenv.mkDerivation {
  pname = "smartdns-rules-adrules";
  version = "20231113";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/StevenBlack/hosts/82047cac55e5e57a77892e51f64e98233b4038ce/hosts";
    sha256 = "sha256-vRo2jVMEkz4FFRmcAh8QNw9QXsyeLxbPP7i0IDIurNA=";
  };

  unpackPhase = ''
    runHook preUnpack
  '';

  installPhase = ''
    cat $src | grep -v "^#" | awk '{print "address /"$2"/#"}' > stevenblocks-smartdns.conf
    install -Dm644 stevenblocks-smartdns.conf $out/stevenblocks-smartdns.conf
  '';

  meta = with lib; {
    description = "L🔒 Consolidating and extending hosts files from several well-curated sources. Optionally pick extensions for porn, social media, and other categories.";
    homepage = "https://github.com/StevenBlack/hosts";
    license = licenses.mit;
  };
}