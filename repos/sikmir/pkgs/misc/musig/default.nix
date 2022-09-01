{ stdenv, lib, fetchFromGitHub, buildGoModule, pkg-config, portaudio }:

buildGoModule rec {
  pname = "musig";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "sfluor";
    repo = pname;
    rev = version;
    hash = "sha256-FL9FkNOR6/WKRKFroFE3otBM5AYFvyj71QySY3EOQMA=";
  };

  vendorHash = "sha256-5V1TojK+/AqurYY1PaeK8dkXV+6gL7IGKaiuyJvsQUE=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ portaudio ];

  ldflags = [ "-X main.VERSION=${version}" ];

  doInstallCheck = true;

  installCheckPhase = "$out/bin/musig --version | grep ${version} > /dev/null";

  meta = with lib; {
    description = "A shazam like tool to store songs fingerprints and retrieve them";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
