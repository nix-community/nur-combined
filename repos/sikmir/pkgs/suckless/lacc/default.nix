{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "lacc";
  version = "2021-07-10";

  src = fetchFromGitHub {
    owner = "larmel";
    repo = pname;
    rev = "ebb03267c48f22f692329f3351ddc432766903de";
    hash = "sha256-pfKjTUSCSHWI/JvYZYpCVaFt3PAcj/4jOHgDwM9PZ/E=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A simple, self-hosting C compiler";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
