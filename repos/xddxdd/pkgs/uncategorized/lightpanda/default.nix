{
  fetchurl,
  nix-update-script,
  stdenv,
  lib,
  autoPatchelfHook,
  curl,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lightpanda";
  version = "0.4.0";
  src =
    if stdenv.hostPlatform.isx86_64 then
      fetchurl {
        url = "https://github.com/lightpanda-io/browser/releases/download/${finalAttrs.version}/lightpanda-x86_64-linux";
        hash = "sha256-v8+b1+gJObhyMqoRSknY85f1GvDCYy2fxY1KbUOGYk8=";
      }
    else if stdenv.hostPlatform.isAarch64 then
      fetchurl {
        url = "https://github.com/lightpanda-io/browser/releases/download/${finalAttrs.version}/lightpanda-aarch64-linux";
        hash = "sha256-TA7LKLT8+21bzoLshuFfxs3onOoWjPOEBJTw7iZ1WFI=";
      }
    else
      throw "Unsupported architecture";

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

  passthru.updateScript = nix-update-script { };
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
