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
  version = "3.7.2";

  src = fetchFromGitHub {
    owner = "anhoder";
    repo = "go-musicfox";
    rev = "v${version}";  
    hash = "sha256-Wc9HFvBSLQA7jT+LJj+tyHzRbszhR2XD1/3C+SdrAGA=";
  };
   
  vendorHash = "sha256-n+xGu9AUFxAfkZZa26HkWWWswzdW4Sr3Adoa2aqyTXk=";
  
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
