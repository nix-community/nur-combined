{
  clangStdenv,
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkg-config,
  alsa-lib,
  flac,
}:

buildGoModule.override { stdenv = clangStdenv; } rec {
  pname = "go-musicfox";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "anhoder";
    repo = "go-musicfox";
    rev = "v${version}";  
    hash = "sha256-IXB5eOXVtoe21WbQa9x5SKcgUpgyjVx48998vdccMPM=";
  };
   
  vendorHash = "sha256-LBN6ZiiabWJNuXIIpE+HT8ODpcixLAcg13WYwDyDbtA=";
  
  deleteVendor = true;
  
  nativeBuildInputs = [ pkg-config ];
  
  buildInputs = [ alsa-lib flac ];

  subPackages = [ "cmd/musicfox.go" ];

  doCheck = false;
  
  meta = with lib; {
    description = "Yet another netease music client written in Go. ";
    homepage = "https://github.com/anhoder/${pname}";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
