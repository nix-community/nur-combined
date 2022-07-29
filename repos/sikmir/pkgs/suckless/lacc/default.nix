{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2022-05-21";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = "lacc";
    rev = "30839843daaff9d87574b5854854c9ee4610cdcd";
    hash = "sha256-aJDc0zqzdOciBxF06tps9Ow9YL3WKgZmZC74wxju9rs=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  doCheck = false;
  checkFlags = [ "-C test" ];
  checkTarget = "all";

  meta = with lib; {
    description = "A simple, self-hosting C compiler";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
