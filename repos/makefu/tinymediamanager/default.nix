{ stdenv, lib, pkgs, fetchurl,libmediainfo,libzen,jre }:
let
  tmm-bin = pkgs.writers.writeDash "tinymediamanager" ''
    TMMDIR=$(dirname $(readlink -f $0))/../lib/tmm
    tmp=$(mktemp -d) # workaround for unwriteable base directory
    trap 'rm -rf $tmp' INT TERM EXIT
    cd "$tmp"
    LD_LIBRARY_PATH=${lib.makeLibraryPath [ libmediainfo libzen ]} \
      ${jre}/bin/java \
        -Dappbase=https://www.tinymediamanager.org/ \
        -Dtmm.contentfolder=$HOME/.config/tmm \
        -classpath "$TMMDIR/tmm.jar:$TMMDIR/lib/*" \
        org.tinymediamanager.TinyMediaManager $@
  '';
in
stdenv.mkDerivation rec {
  pname = "tinymediamanager";
  version = "3.1.5";

  src = fetchurl {
    url = "http://release.tinymediamanager.org/v3/dist/tmm_${version}_linux.tar.gz";
    sha256 = "01nlbkiwvw1cdwrxpdvkkc6g5zrjig22hxbyv1i44ay4wi6vmcax";
  };
  sourceRoot = ".";

  phases = [ "unpackPhase" "installPhase" ];
  installPhase = ''
    install -D ${tmm-bin} $out/bin/tinymediamanager
    install -d $out/lib
    cp -r . $out/lib/tmm
  '';

  meta = {
    homepage = http://users.eastlink.ca/~doiron/bin2iso/ ;
    description = "converts bin+cue to iso";
    license = lib.licenses.gpl3;
  };
}
