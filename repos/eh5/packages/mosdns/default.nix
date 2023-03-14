{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "mosdns";
  version = "v5.1.2";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosdns";
    rev = version;
    fetchSubmodules = false;
    sha256 = "sha256-mbCGfbtrm6/InQC4kuo5cBfAi0qELIzEsdllTsXtglA=";
  });
  vendorSha256 = "sha256-fWc9vJV7vnpfctK0JZt4ONUTN4ub29Y+VyrwUyk8pUw=";
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
