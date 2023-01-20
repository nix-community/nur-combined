{
  stdenv,
  lib,
  fetchFromGitHub,
  buildGoModule,
  xz,
}:

buildGoModule rec {
  pname = "payload-dumper-go";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "ssut";
    repo = "payload-dumper-go";
    rev = "${version}";
    hash = "sha256-P20/Nd2YOW9A9/OkpavVRBAi/ueYp812zZvVLnwX67Y=";
  };
  
  vendorHash = "sha256-CqIZFMDN/kK9bT7b/32yQ9NJAQnkI8gZUMKa6MJCaec=";
  
  buildInputs = [ xz ];

  meta = with lib; {
    description = "An android OTA payload dumper written in Go. ";
    homepage = "https://github.com/ssut/${pname}";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}
