{ lib, stdenv, fetchFromGitHub, memstreamHook }:

stdenv.mkDerivation rec {
  pname = "chibicc";
  version = "2020-12-07";

  src = fetchFromGitHub {
    owner = "rui314";
    repo = "chibicc";
    rev = "90d1f7f199cc55b13c7fdb5839d1409806633fdb";
    hash = "sha256-sGSPQv9JPXTnyv+7CnmzWq1objCJRctK4wKII8GM26s=";
  };

  buildInputs = lib.optional stdenv.isDarwin memstreamHook;

  installPhase = ''
    install -Dm755 chibicc -t $out/bin
  '';

  meta = with lib; {
    description = "A small C compiler";
    inherit (src.meta) homepage;
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ maintainers.sikmir ];
  };
}
