{
  lib,
  stdenvNoCC,
  replaceVars,

  hmcl-dev,

  jdk,
  zip,

  sources,
  source-src ? sources.hmcl-dev-src,
  source-bin ? sources.hmcl-dev-bin,
  source-exe ? sources.hmcl-dev-exe,

  easytierDiscoveryNodes ? [ ],
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "hmcl-dev-windows";

  inherit (source-exe) version;
  src = source-exe.src;

  prePatch = ''
    install -Dm644 "${source-src.src}/$regionUtilsJavaPath" "$regionUtilsJavaPath"
    install -Dm644 "${source-src.src}/$terracottaNodeListJavaPath" "$terracottaNodeListJavaPath"
  '';

  patches = [
    ../hmcl-dev/0003-nix-keep-downloads-enabled.patch
  ]
  ++ lib.optional (easytierDiscoveryNodes != [ ]) (
    replaceVars ../hmcl-dev/0004-nix-add-easytier-nodes.patch {
      NODES = lib.concatMapStringsSep ", " builtins.toJSON easytierDiscoveryNodes;
    }
  );

  dontUnpack = true;
  dontConfigure = true;

  env = {
    inherit (hmcl-dev) regionUtilsJavaPath terracottaNodeListJavaPath;
  };

  nativeBuildInputs = [
    jdk
    zip
  ];

  buildPhase = ''
    runHook preBuild

    javac -cp "${source-bin.src}" \
      -sourcepath "${source-src.src}/HMCLCore/src/main/java" \
      -implicit:none -d out "$regionUtilsJavaPath"

    javac -cp "${source-bin.src}" \
      -sourcepath "${source-src.src}/HMCLCore/src/main/java" \
      -implicit:none -d classes "$terracottaNodeListJavaPath"
  ''
  + ''
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/hmcl.exe"
    zip -A "$out/hmcl.exe"
    (
      cd classes
      zip -q -X -r "$out/hmcl.exe" org
    )

    runHook postInstall
  '';

  passthru = {
    nodePatch = replaceVars ../hmcl-dev/0004-nix-add-easytier-nodes.patch {
      NODES = lib.concatMapStringsSep ", " builtins.toJSON easytierDiscoveryNodes;
    };
  };

  inherit (hmcl-dev) meta;
})
