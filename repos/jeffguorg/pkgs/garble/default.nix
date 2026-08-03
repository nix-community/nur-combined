{
  lib,
  stdenv,
  buildGoModule,
  git,
  versionCheckHook,
  replaceVars,
  nix-update-script,
  sources,
}:

buildGoModule (finalAttrs: {
  pname = "garble";
  version = lib.removePrefix "v" sources.garble.version;

  src = sources.garble.src;

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-buildid=00000000000000000000" # length=20
  ];

  patches = [
    (replaceVars ./0001-Add-version-info.patch {
      inherit (finalAttrs) version;
    })
  ];

  checkFlags = [
    "-skip"
    # crossbuild cross-compiles to darwin, needs a macOS toolchain;
    # atomic cross-compiles to 386, needs 32-bit multilib
    "TestScript/gogarble|TestScript/gotoolchain|TestScript/tiny|TestScript/crossbuild|TestScript/atomic"
  ];

  vendorHash = "sha256-F0Jc15ulA+qRDZu5W3FU9dZ+oXq8lGXP4dQeWnZwYbk=";

  # Used for some of the tests.
  nativeCheckInputs = [
    git
    versionCheckHook
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
    export WORK=$(mktemp -d)
  '';

  # Several tests fail with
  # FAIL: testdata/script/goenv.txtar:27: "$WORK/.temp 'quotes' and spaces" matches "garble|importcfg|cache\\.gob|\\.go"
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];
  versionCheckProgramArg = "version";
  doInstallCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Obfuscate Go code by wrapping the Go toolchain";
    homepage = "https://github.com/burrowers/garble/";
    maintainers = with lib.maintainers; [
      davhau
      bot-wxt1221
    ];
    license = lib.licenses.bsd3;
    mainProgram = "garble";
  };
})
