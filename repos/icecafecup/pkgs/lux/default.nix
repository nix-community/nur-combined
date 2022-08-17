{ lib, buildGoModule, fetchFromGitHub, ffmpeg, ... }:

buildGoModule rec {
  pname = "lux";
  version = "0.15.0";
  src = fetchFromGitHub {
    owner = "iawia002";
    repo = "lux";
    rev = "v${version}";
    sha256 = "sha256-fZR+Q0duITZq3Ynr2WTZAhDnmEkXrT2gXUlpuN0+aFo=";
  };

  buildInputs = [ ffmpeg ];

  vendorSha256 = "sha256-SHUtyfGRGriEaESo6th7gGQn6V4REdk3XT0ZlGwky7E=";

  buildPhase = ''
    buildFlagsArray=(-v -p $NIX_BUILD_CORES -ldflags="-s -w")
    runHook preBuild
    go build "''${buildFlagsArray[@]}" -o lux
    runHook postBuild
  '';

  installPhase = ''
    	mkdir -p $out/bin
    	cp lux $out/bin
  '';

  meta = with lib; {
    description = "Fast and simple video download library and CLI tool written in Go";
    homepage = "https://github.com/iawia002/lux";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
