{
  stdenv,
  lib,
  sources,
  autoPatchelfHook,
  curl,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lightpanda";
  inherit
    (
      if stdenv.isx86_64 then
        sources.lightpanda-amd64
      else if stdenv.isAarch64 then
        sources.lightpanda-arm64
      else
        throw "Unsupported architecture"
    )
    version
    src
    ;

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ curl ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/lightpanda

    runHook postInstall
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doCheck = false;
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/lightpanda";
  versionCheckProgramArg = "version";

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Headless browser designed for AI and automation";
    homepage = "https://lightpanda.io";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "lightpanda";
  };
})
