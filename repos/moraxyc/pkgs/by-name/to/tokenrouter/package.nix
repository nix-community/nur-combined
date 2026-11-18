{
  lib,
  buildGo127Module,
  callPackage,
  go_1_27,
  versionCheckHook,

  sources,
  source ? sources.tokenrouter,
}:

buildGo127Module (finalAttrs: {
  inherit (source)
    pname
    version
    src
    vendorHash
    ;

  modRoot = "backend";

  patches = [
    ./redis-unix-socket.patch
    ./unix-socket.patch
  ];

  subPackages = [ "cmd/server" ];

  tags = [ "embed" ];

  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
    "-X main.BuildType=release"
  ];

  postPatch = lib.optionalString (lib.versionOlder go_1_27.version "1.27.4") ''
    substituteInPlace backend/go.mod --replace-fail "go 1.27.4" "go ${go_1_27.version}"
  '';

  postConfigure = ''
    rm -rf internal/web/dist
    cp -r ${finalAttrs.passthru.frontend} internal/web/dist
  '';

  postInstall = ''
    mv $out/bin/{server,tokenrouter}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-version";

  passthru = {
    frontend = callPackage ./frontend.nix {
      inherit source;
      meta = lib.removeAttrs finalAttrs.meta [ "mainProgram" ];
    };
  };

  meta = {
    description = "Open source unified LLM gateway";
    homepage = "https://github.com/TokenFlux/TokenRouter";
    changelog = "https://github.com/TokenFlux/TokenRouter/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "tokenrouter";
  };
})
