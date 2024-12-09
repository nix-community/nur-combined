{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "kcptun";
  version = "unstable-2024-05-16";
  src = fetchFromGitHub {
    owner = "xtaci";
    repo = "kcptun";
    rev = "f8cae52c52d14dd3d8ca1fe424c50ac13caee6b8";
    fetchSubmodules = false;
    sha256 = "sha256-v9xwDE8xFDH64XyRaKbLs2TXDldNyvOMRXkfRp0JX5s=";
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
