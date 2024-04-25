{ pkgs, lib, buildGoModule, fetchFromGitHub, ... }:
let
  pname = "snips-sh";
  version = "0.3.2";
  hash = "sha256-MCCMowqBXkLINXs8EUtPdQn6pd95/80vqGj+mIj4I5w=";
  vendorHash = "sha256-eeaU+A0KAbIMx+NbXXL1qQNRre92j4wobxDNxrfLPN0=";
  src = fetchFromGitHub {
    # robherley / snips.sh
    owner = "robherley";
    repo = "snips.sh";
    rev = "v${version}";
    inherit hash;
  };
in
buildGoModule {
  inherit pname vendorHash src version;

  buildInputs = with pkgs; [
    libtensorflow
    sqlite
  ];
  meta = with lib; {
    description = "passwordless, anonymous SSH-powered pastebin with a human-friendly TUI and web UI";
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = "https://snips.sh";
  };
}
