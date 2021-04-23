{ lib, stdenv, fetchFromGitHub, go }:

stdenv.mkDerivation rec {
  pname = "gloggery";
  version = "2020-10-11";

  src = fetchFromGitHub {
    owner = "kconner";
    repo = pname;
    rev = "49707b008cd6e3fb3ecb453a472051644fb319eb";
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
