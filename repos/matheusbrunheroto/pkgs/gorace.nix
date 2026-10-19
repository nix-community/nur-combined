{
  lib,
  buildGoModule,
  fetchurl,
}:

buildGoModule {
  pname = "gorace";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/MatheusBrunheroto/gorace/releases/download/v1.0.0/gorace-1.0.0.tar.gz";
    hash = "sha256-9Nc4CDi5qneBaYIUjvhXiFc+KCM5ZrFW/2XBNXQ/FZc=";
  };
  vendorHash = "sha256-uy8/F8FW2cqte7O7KS1x89Jy3uEdiyGz41h1emyQ72E=";

  env.CGO_ENABLED = 0;
  subPackages = [ "." ];

  postInstall = ''
    install -Dm644 README.md "$out/share/doc/gorace/README.md"
    install -Dm644 assets/help.txt "$out/share/doc/gorace/help.txt"
  '';

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck
    "$out/bin/gorace" --help > help-output.txt
    grep -F 'GORACE(1)' help-output.txt
    runHook postInstallCheck
  '';

  meta = {
    description = "HTTP race condition testing tool";
    homepage = "https://github.com/MatheusBrunheroto/gorace";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    mainProgram = "gorace";
  };
}
