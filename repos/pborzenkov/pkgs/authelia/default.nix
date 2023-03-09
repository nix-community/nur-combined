{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildGoModule,
}: let
  ver = "4.37.5";
  html = fetchurl {
    url = "https://github.com/authelia/authelia/releases/download/v${ver}/authelia-v${ver}-public_html.tar.gz";
    sha256 = "sha256-bU+0GC3Nn9OrwQ+dW5f2rTHOrZdaqNUvfHKjQvOEM5g=";
  };
in
  buildGoModule rec {
    pname = "authelia";
    version = ver;

    src = fetchFromGitHub {
      owner = "authelia";
      repo = "authelia";
      rev = "v${version}";
      sha256 = "sha256-xsdBnyPHFIimhp2rcudWqvVR36WN4vBXbxRmvgqMcDw=";
    };

    vendorSha256 = "sha256-mzGE/T/2TT4+7uc2axTqG3aeLMnt1r9Ya7Zj2jIkw/w=";

    subPackages = ["cmd/authelia"];

    ldflags = ["-X github.com/authelia/authelia/v4/internal/utils.BuildTag=v${version}"];

    prePatch = ''
      rm -rf internal/server/public_html
      tar -xzf ${html} -C internal/server
    '';

    meta = with lib; {
      description = "The Single Sign-On Multi-Factor portal for web apps.";
      homepage = "https://github.com/authelia/authelia";
      license = with licenses; [asl20];
      maintainers = with maintainers; [pborzenkov];
    };
  }
