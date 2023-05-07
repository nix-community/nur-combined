{ lib, fetchFromGitHub, buildGoModule, testers, gemget }:

buildGoModule rec {
  pname = "gemget";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "makeworld-the-better-one";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-P5+yRaf2HioKOclJMMm8bJ8/BtBbNEeYU57TceZVqQ8=";
  };

  vendorSha256 = "sha256-l8UwkFCCNUB5zyhlyu8YC++MhmcR6midnElCgdj50OU=";

  passthru.tests.version = testers.testVersion {
    package = gemget;
    version = "v${version}";
  };

  meta = with lib; {
    description = "Command line downloader for the Gemini protocol";
    homepage = "https://github.com/makeworld-the-better-one/gemget";
    license = with licenses; [ mit ];
  };
}
