{
  lib,
  buildGoModule,
  fetchFromGitHub,
  clojure,
  writableTmpDirAsHomeHook,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "glojure";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "glojurelang";
    repo = "glojure";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WzyslO3YaGPJnINDSjk3AcjC/raVh5c5K2a6EBZC4Rk=";
  };

  vendorHash = "sha256-bofeBp8aa/I5jhblv+BhqHX9tmD1hDgUBwEFJpLH/A8=";

  nativeBuildInputs = [
    clojure
    writableTmpDirAsHomeHook
  ];

  strictDeps = true;

  ldflags = [
    "-s"
    "-w"
  ];

  checkFlags =
    let
      # Requires network access
      skippedTests = [
        "FuzzCLJConformance/seed#2"
        "FuzzCLJConformance/seed#11"
        "FuzzCLJConformance/seed#12"
      ];
    in
    [
      "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$"
    ];

  passthru.updateScript = nix-update-script { };

  meta = {
    mainProgram = "glj";
    description = "Clojure interpreter hosted on Go, with extensible interop support";
    homepage = "https://github.com/glojurelang/glojure";
    changelog = "https://github.com/glojurelang/glojure/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.epl10;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
