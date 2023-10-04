{ lib
, buildGoModule
, fetchFromGitHub
}:
buildGoModule rec {
  pname = "mosdns";
  version = "5.2.1";
  src = fetchFromGitHub ({
    owner = "IrineSistiana";
    repo = "mosdns";
    rev = "v${version}";
    fetchSubmodules = false;
    sha256 = "sha256-AECvym7rN9sM1n37G9+Ruro61n6+VtybpAoFUbkHfFw=";
  });
  vendorSha256 = "sha256-shVjs2lFHi9j2Bc0ha4NylIYsvm0Amzc1dxcqhe/3Jk=";
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
