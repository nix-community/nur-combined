{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "go-haystack";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "hybridgroup";
    repo = "go-haystack";
    rev = "v${version}";
    hash = "sha256-u78UAhMGtAB3ouxDZQ4WMEGCdjK9PNYXzi/9v2BZ+Sw=";
  };

  modRoot = "cmd/haystack";
  subPackages = [ "." ];

  #vendorHash = lib.fakeSha256;

  vendorHash = "sha256-IUyWdP6rcsuyCg7OMmdpJV4NSL6JOPZe61ECSKl1N6I=";

  ldflags = [ "-s" "-w" ];

  meta = {
    description = "Track personal Bluetooth devices via Apple's \"Find My\" network using OpenHaystack and Macless-Haystack with tools written in Go/TinyGo. No Apple hardware required";
    homepage = "https://github.com/hybridgroup/go-haystack.git";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "go-haystack";
  };
}
