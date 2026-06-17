{
  lib,
  stdenv,
  buildGoModule,
  version,
  src,
}:

let
  hostGoArch =
    {
      x86_64-linux = "amd64";
      aarch64-linux = "arm64";
    }
    .${stdenv.hostPlatform.system}
      or (throw "waveterm: unsupported system ${stdenv.hostPlatform.system}");
  hostNormArch = if hostGoArch == "amd64" then "x64" else hostGoArch;

  # waveterm bakes a build time string into the binaries; pin it for reproducibility.
  buildTime = "0";
in
buildGoModule {
  pname = "waveterm-backend";
  inherit version src;

  vendorHash = "sha256-EyDS/AB56+yE54XhwnQhalNPZwMM/Hp2kWQN824yq0k=";

  # The wshrpc/typescript bindings and config schema are committed in the tree,
  # so the codegen step can be skipped and we only compile the binaries.
  buildPhase = ''
    runHook preBuild

    mkdir -p dist/bin

    echo "building wavesrv (${hostNormArch})"
    CGO_ENABLED=1 go build \
      -tags "osusergo,sqlite_omit_load_extension" \
      -ldflags "-X main.BuildTime=${buildTime} -X main.WaveVersion=${version}" \
      -o dist/bin/wavesrv.${hostNormArch} \
      cmd/server/main-server.go

    buildWsh() {
      local goos="$1" goarch="$2" ext="$3"
      local narch="$goarch"
      [ "$goarch" = "amd64" ] && narch="x64"
      echo "building wsh ($goos/$narch)"
      CGO_ENABLED=0 GOOS="$goos" GOARCH="$goarch" go build \
        -ldflags "-s -w -X main.BuildTime=${buildTime} -X main.WaveVersion=${version}" \
        -o "dist/bin/wsh-${version}-$goos.$narch$ext" \
        cmd/wsh/main-wsh.go
    }

    # wsh is shipped for every platform Wave can connect to and install itself on.
    buildWsh darwin arm64 ""
    buildWsh darwin amd64 ""
    buildWsh linux arm64 ""
    buildWsh linux amd64 ""
    buildWsh linux mips ""
    buildWsh linux mips64 ""
    buildWsh windows amd64 ".exe"
    buildWsh windows arm64 ".exe"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r dist/bin $out/bin
    runHook postInstall
  '';

  doCheck = false;

  meta = {
    description = "Wave Terminal backend binaries (wavesrv server and wsh helper)";
    homepage = "https://www.waveterm.dev";
    license = lib.licenses.asl20;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
