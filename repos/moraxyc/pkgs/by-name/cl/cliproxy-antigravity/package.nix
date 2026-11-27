{
  lib,
  stdenv,
  buildGoModule,
  python3,
  runtimeShell,

  sources,
  source ? sources.cliproxy-antigravity,
}:
let
  inherit (stdenv.hostPlatform.go) GOOS GOARCH;
  library = "cliproxy-antigravity${stdenv.hostPlatform.extensions.sharedLibrary}";
in
buildGoModule {
  inherit (source) pname version src;

  vendorHash = null;
  env.CGO_ENABLED = "1";

  postPatch = ''
    substituteInPlace login.go login_test.go scripts/abi_smoke.py \
      --replace-fail '#!/bin/sh' '#!${runtimeShell}'
    substituteInPlace testmain_test.go \
      --replace-fail 'os.Setenv("PATH", home+":/usr/bin:/bin")' 'os.Setenv("PATH", home+":"+os.Getenv("PATH"))'
  '';

  buildPhase = ''
    runHook preBuild

    go build -buildmode=c-shared -ldflags="-s -w" -o ${library} .

    runHook postBuild
  '';

  nativeCheckInputs = [ python3 ];
  checkPhase = ''
    runHook preCheck

    export HOME="$(mktemp -d)"
    go test ./...
    python3 scripts/abi_smoke.py ./${library}

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 ${library} "$out/lib/cliproxyapi/plugins/${GOOS}/${GOARCH}/${library}"

    runHook postInstall
  '';

  meta = {
    description = "Antigravity CLI provider plugin for CLIProxyAPI";
    homepage = "https://github.com/adeebahmad01/cliproxy-antigravity";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
