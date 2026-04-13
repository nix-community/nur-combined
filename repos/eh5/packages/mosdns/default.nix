{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "mosdns";
  version = "5.3.4";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosdns";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-N0JY0brs9IXx3L+sz66JniRaBzY0bGD8PawJ1WA3tkw=";
  });
  vendorHash = "sha256-FfCA5204MP+m5nkzj/jLDh5NzpD1EtrL7owmcvZhOBU=";
  doCheck = false;

  buildPhase = ''
    buildFlagsArray=(-v -p $NIX_BUILD_CORES -ldflags="-s -w")
    runHook preBuild
    go build "''${buildFlagsArray[@]}" -o mosdns ./
    runHook postBuild
  '';

  installPhase = ''
    install -Dm755 mosdns -t $out/bin
  '';

  meta = with lib; {
    description = "A DNS proxy server";
    homepage = "https://github.com/IrineSistiana/mosdns";
    license = licenses.gpl3;
  };
}
