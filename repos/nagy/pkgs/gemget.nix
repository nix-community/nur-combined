{ lib, fetchFromGitHub, buildGoModule, testers, gemget }:

buildGoModule rec {
  pname = "gemget";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "makew0rld";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-P5+yRaf2HioKOclJMMm8bJ8/BtBbNEeYU57TceZVqQ8=";
  };

  vendorHash = "sha256-l8UwkFCCNUB5zyhlyu8YC++MhmcR6midnElCgdj50OU=";

  ldflags = [ "-s" "-w" ];

  passthru.tests.version = testers.testVersion {
    package = gemget;
    version = "v${version}";
  };

  meta = with lib; {
    inherit (src.meta) homepage;
    description = "Command line downloader for the Gemini protocol";
    license = licenses.mit;
  };
}
