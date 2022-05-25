{ stdenv, lib, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "diskgraph";
  version = "2021-05-13";

  src = fetchFromGitHub {
    owner = "stolk";
    repo = "diskgraph";
    rev = "8d1998ca9a05e19c822f24b6285c458a6bf023ea";
    sha256 = "sha256-OaOp+5WeMSJBum+bLDil936rpKHWyzBxGCxSZWe/wZg=";
  };

  installPhase = ''
    install -D -m755 diskgraph $out/bin/diskgraph
  '';

  meta = with lib; {
    description = "Graphs the disk IO in a linux terminal";
    homepage = "https://github.com/stolk/diskgraph";
    license = licenses.mit;
	platforms = platforms.linux;
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
