{ cacert
, curl
, fetchFromGitHub
, git
, lib
, libzip
, stdenv
, nodejs
, nodePackages
, pkg-config
, radare2
, wget }:

stdenv.mkDerivation rec {
  pname = "r2frida";
  version = "5.1.3";

  src = fetchFromGitHub {
    owner = "nowsecure";
    repo = pname;
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "0yprvy0ryy1flg8l2s327bvbpv0fjx4d98rb1pqdcx5avbch8ijk";
  };

  nativeBuildInputs = [ curl git pkg-config ];

  propagatedBuildInputs = [ libzip nodejs nodePackages.npm radare2 ];

  # Enable curl which needs SSL certificates during evaluation.
  shellHook = ''
    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
  '';

  meta = with lib; {
    broken = true;
    description = "Radare2 and Frida better together";
    license = licenses.mit;
    homepage = "https://github.com/nowsecure/r2frida";
    maintainers = let dschrempf = import ../../dschrempf.nix; in [ dschrempf ];
    platforms = platforms.all;
  };
}
