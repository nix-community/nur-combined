{ lib, stdenv, fetchFromGitHub, go }:

stdenv.mkDerivation rec {
  pname = "gloggery";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "kconner";
    repo = "gloggery";
    rev = "v${version}";
    hash = "sha256-tWTJXRtm/8cSEbK40fi9PVOg9w/qC0CBFZWyT7vSo80=";
  };

  nativeBuildInputs = [ go ];

  makeFlags = [ "GOCACHE=$(TMPDIR)/go-cache" "HOME=$(out)" ];

  preInstall = "install -dm755 $out/{bin,share}";

  postInstall = "mv $out/.gloggery $out/share/glogger";

  meta = with lib; {
    description = "Gemtext blog static site generator";
    inherit (src.meta) homepage;
    license = licenses.free;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
