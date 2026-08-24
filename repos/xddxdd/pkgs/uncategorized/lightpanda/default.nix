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
  inherit
    (
      if stdenv.hostPlatform.isx86_64 then
        {
          pname = "lightpanda-amd64";
          version = "0.3.7";
          src = fetchurl {
            url = "https://github.com/lightpanda-io/browser/releases/download/0.3.7/lightpanda-x86_64-linux";
            hash = "sha256-iVM5sCIFFxoYHd50OuAGi7RWSIQHb+rISCusqcISqlo=";
          };
        }
      else if stdenv.hostPlatform.isAarch64 then
        {
          pname = "lightpanda-arm64";
          version = "0.3.7";
          src = fetchurl {
            url = "https://github.com/lightpanda-io/browser/releases/download/0.3.7/lightpanda-aarch64-linux";
            hash = "sha256-TA7LKLT8+21bzoLshuFfxs3onOoWjPOEBJTw7iZ1WFI=";
          };
        }
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
