{ pkgs, lib, buildGoModule, fetchFromGitHub, ... }:
let
  pname = "snips-sh";
  version = "0.4.2";
  hash = "sha256-IjGXGY75k9VeeHek0V8SrIElmiQ+Q2P5gEDIp7pmQd8=";
  vendorHash = "sha256-Lp3yousaDkTCruOP0ytfY84vPmfLMgBoTwf+7Q7Q0Lc=";
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
  tags = ["noguesser"];

  buildInputs = with pkgs; [
    # libtensorflow
    sqlite
  ];
  meta = with lib; {
    description = "passwordless, anonymous SSH-powered pastebin with a human-friendly TUI and web UI";
    license = licenses.mit;
    platforms = platforms.linux;
    homepage = "https://snips.sh";
  };
}
