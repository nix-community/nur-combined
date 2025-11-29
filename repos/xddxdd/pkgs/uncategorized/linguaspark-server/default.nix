{
  sources,
  lib,
  rustPlatform,
  pkg-config,
  openssl,
  callPackage,
  runCommand,
  autoPatchelfHook,
  buildArch ? null,
}:
let
  linguaspark-core = callPackage ./linguaspark-core.nix { inherit sources buildArch; };
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (sources.linguaspark-server) pname version src;

  nativeBuildInputs = [
    pkg-config
    autoPatchelfHook
  ];
  buildInputs = [ openssl ];

  cargoDeps =
    let
      deps = rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) pname version src;
        hash = "sha256-ztttmouKz0SmQ3HDFnSfTdOpj9DS2uRQmKwiuez41mA=";
      };
    in
    runCommand "${finalAttrs.pname}-deps" { } ''
      cp -r ${deps} $out
      chmod -R +w $out

      TARGET_DIR=$(echo "$out"/linguaspark-*)
      install -Dm755 ${linguaspark-core}/lib/liblinguaspark.so "$TARGET_DIR/linguaspark/build/liblinguaspark.so"
    '';

  postInstall = ''
    install -Dm755 ${linguaspark-core}/lib/liblinguaspark.so "$out/lib/liblinguaspark.so"
  '';

  passthru = { inherit linguaspark-core; };

  meta = {
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Lightweight multilingual translation service based on Rust and Bergamot translation engine, compatible with multiple translation frontend APIs";
    homepage = "https://github.com/LinguaSpark/server";
    license = lib.licenses.agpl3Only;
    platforms = [ "x86_64-linux" ];
  };
})
