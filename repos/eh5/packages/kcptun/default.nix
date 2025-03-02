{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "kcptun";
  version = "unstable-2025-02-25";
  src = fetchFromGitHub {
    owner = "xtaci";
    repo = "kcptun";
    rev = "bc937c57b8a3a3ffa15d5718f16282c3e0c1968b";
    fetchSubmodules = false;
    sha256 = "sha256-GyPBsllRprASS+VmVKusBwIv+QaCt4sQFXFQGdWs/jo=";
  };
  vendorHash = null;
  doCheck = false;

  buildPhase = ''
    buildFlagsArray=(-v -p $NIX_BUILD_CORES -ldflags="-s -w")
    runHook preBuild
    go build "''${buildFlagsArray[@]}" -o $out/bin/kcptun-server ./server
    go build "''${buildFlagsArray[@]}" -o $out/bin/kcptun-client ./client
    runHook postBuild
  '';

  meta = with lib; {
    description = "A Stable & Secure Tunnel based on KCP with N:M multiplexing and FEC.";
    homepage = "https://github.com/xtaci/kcptun";
    license = licenses.mit;
  };
}
