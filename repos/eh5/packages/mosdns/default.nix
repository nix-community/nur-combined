{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "mosdns";
  version = "v5.1.3";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosdns";
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-efgrJikV1s5VENJXYkpvqnxDpj76Zwxo03zeEXNz6ig=";
  });
  vendorSha256 = "sha256-dx7HKmmdrtEDq/at5NFLOU1QU9KH4CSpi8xyrgqPyls=";
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
