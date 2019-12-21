{ stdenv, fetchurl, tcsh, coreutils, pkg-config }:
stdenv.mkDerivation rec {
  version = "20170106";
  name = "ncbi_tools-${version}";
  src = fetchurl {
    url = "https://ftp.ncbi.nih.gov/toolbox/ncbi_tools/old/20170106/ncbi.tar.gz";
    sha256 = "sha256:0rsqby84g0wz344wf9ls5jfmh38gjajz61kxpi81nfwmiynsm22b";
  };

  buildInputs = [ pkg-config ];

  patches = [ ./tbl2asn_too_old.patch ];

  postPatch = ''
    for f in ./ncbi/make/*.csh ./ncbi/make/ln-if-absent; do
      substituteInPlace  $f\
        --replace "/bin/csh" "${tcsh}/bin/tcsh"
    done
    substituteInPlace  ./ncbi/make/ln-if-absent \
      --replace "set path=(/usr/bin /bin)" "set path=${coreutils}/bin"
    substituteInPlace  ./ncbi/platform/linux.ncbi.mk \
      --replace "NCBI_CFLAGS1 = -c" "NCBI_CFLAGS1 = -c -Wno-format-security"
  '';

  sourceRoot = ".";

  buildPhase = ''
      ./ncbi/make/makedis.csh 2>&1 | tee out.makedis.txt
  '';

  installPhase = ''
    mkdir -p $out
    cp -r ncbi/bin $out/
  '';

  meta = with stdenv.lib; {
    platforms = platforms.linux;
  };
}
