{ stdenv, pkgs, fetchgit }:

pkgs.perlPackages.buildPerlPackage rec {
  pname = "debmirror";
  version = "2.25";

  enableParallelBuilding = true;

  src = fetchgit {
    url = "https://anonscm.debian.org/git/collab-maint/debmirror.git";
    rev = "c77e5caa15a4ab6497db5d819614387e647ccf4e";
    sha256 = "1zp8ff9ajw22b4wradnw1hnfcpbyx5ibqzqgk6kp79nsj1dzmm0d";
  };
  preConfigure = ''
    touch Makefile.PL
  '';

  outputs = [ "out" ];

  buildPhase = ''
    make
  '';

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1/
    cp debmirror mirror-size $out/bin
    cp debmirror.1 $out/share/man/man1/
  '';
  propagatedBuildInputs = (with pkgs.perlPackages; [ LockFileSimple LWP]) ++
    (with pkgs; [ rsync patch ed gzip diffutils findutils gnupg1 xz ]);

  meta = {
    description = "mirror apt repos";
    homepage = https://tracker.debian.org/pkg/debmirror;
    license = stdenv.lib.licenses.gpl2;
    platforms = stdenv.lib.platforms.linux;
    maintainers = with stdenv.lib.maintainers; [ makefu ];
  };
}
