 { stdenv, fetchFromGitHub, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:
 buildGoPackage rec {
  name = "u-root-${version}";
  version = "v1.0.0";

  goPackagePath = "github.com/u-root/u-root";

  src = fetchFromGitHub {
    owner = "u-root";
    repo = "u-root";
    rev = version;
    sha256 = "0y1432z4yb71aw1pmyr04v08km9w3p85d287l9yz09slqly5sqq1";
  };

  goDeps = ./deps.nix;

  meta = with stdenv.lib; {
    description = "A fully Go userland! u-root can create a root file system (initramfs) containing a busybox-like set of tools written in Go.";
    license = licenses.bsd3;
    homepage = https://u-root.tk;  # Doesn't redirect from http
    maintainers = with maintainers; [ johnazoidberg ];
    platforms = platforms.all;
  };
 }
