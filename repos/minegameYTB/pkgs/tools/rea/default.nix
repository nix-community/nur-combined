{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  ### REA's `prepare` script (run by `npm pack` even with --ignore-scripts
  ### under npm 10) applies patches/release-please+17.3.0.patch with
  ### `git apply`, which works outside a repository but needs git on PATH.
  git,
  nodejs_22 ? null,
  nodejs_24 ? null,
  nodejs_26 ? null,
  ghidra ? null,
  ### JDK wired into the Ghidra variant; must satisfy the Ghidra
  ### installation's application.java.min bound (25 for Ghidra 12.2).
  jdk ? null,
  withGhidra ? false,
  extraPackages ? [ ],
}:

let
  ### Keep in sync with the `frida` dependency in package-lock.json
  fridaVersion = "17.23.2";

  fridaPlatforms = {
    x86_64-linux = {
      asset = "linux-x64";
      hash = "sha256-n6j2aM6R6wNxPoVk3k+PveIyIz7pHXKcFnc/3hHbrpU=";
    };
    aarch64-linux = {
      asset = "linux-arm64";
      hash = "sha256-EQg/AWpCnodQbNaBZr0URdqP69UGok7fP2xKmno+qf4=";
    };
    x86_64-darwin = {
      asset = "darwin-x64";
      hash = "sha256-+JU7CXIMvczSccHWyqT/8IVHSp8k3vP+RhYFJqrNtAs=";
    };
    aarch64-darwin = {
      asset = "darwin-arm64";
      hash = "sha256-hQ+6Igotm2quKCrG3eN/SIR+c1l7egbWSHN/+a3cM0A=";
    };
  };

  fridaPlatform =
    fridaPlatforms.${stdenv.hostPlatform.system}
      or (throw "rea: unsupported platform for the frida prebuilt binding: ${stdenv.hostPlatform.system}");

  ### The `frida` package downloads this binding from GitHub during npm install,
  ### which is not possible in the Nix sandbox.
  fridaBinding = fetchurl {
    url = "https://github.com/frida/frida/releases/download/${fridaVersion}/frida-v${fridaVersion}-napi-v8-${fridaPlatform.asset}.tar.gz";
    inherit (fridaPlatform) hash;
  };
in
buildNpmPackage rec {
  pname = "rea";
  ### 6.9.0 or later is required for Ghidra 12.2: REA 6.8.0 only accepted
  ### the 12.1.x line, while nixpkgs ships Ghidra 12.2.
  version = "6.9.0";

  src = fetchFromGitHub {
    owner = "morluto";
    repo = "rea";
    rev = "rea-agents-${version}";
    hash = "sha256-n96fXl7OKRIlQ/nKGBDjN8kT4RIr2atgrQAU379lsoQ=";
  };

  ### REA requires ^22.23.4 || ^24.22.1 || >=26.12.1
  ### Prefer the 24 line (upstream pins 24.22.1 in .nvmrc), then 22: Node 26
  ### removed the `transform`/`sourceMap` options of
  ### `stripTypeScriptTypes` (v26.0.0), which REA's verifier source loader
  ### (metadata:check) still needs — see morluto/rea#8597. Node 22/24 keep
  ### mode "transform", so 26 is only a last resort.
  compatibleNodejs =
    let
      versionAtLeast = lib.versionAtLeast or (a: b: (builtins.compareVersions a b) >= 0);
      isCompatible =
        n:
        n != null
        && (
          (lib.hasPrefix "26." n.version && versionAtLeast n.version "26.12.1")
          || (lib.hasPrefix "24." n.version && versionAtLeast n.version "24.22.1")
          || (lib.hasPrefix "22." n.version && versionAtLeast n.version "22.23.4")
        );
      candidates = builtins.filter isCompatible [
        nodejs_24
        nodejs_22
        nodejs_26
      ];
    in
    if candidates == [ ] then null else builtins.head candidates;

  nodejs = if compatibleNodejs != null then compatibleNodejs else nodejs_26;
  npmDepsHash = "sha256-xFNYn2vxfk8unZyJQ3YWOO3fFb3iJVU6Alav0A+TiSI=";

  ### Build the same way as the upstream CI (Turbo compile + generated skills)
  npmBuildScript = "build:cached";

  ### Native install scripts cannot download prebuilt binaries in the sandbox
  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [
    makeWrapper
    git
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  ### Avoid running lifecycle scripts again during packaging
  npmPackFlags = [ "--ignore-scripts" ];
  npmPruneFlags = [ "--ignore-scripts" ];

  preBuild = ''
    ### Install the frida native binding fetched above
    mkdir -p node_modules/frida/build
    tar -xzf ${fridaBinding} -C node_modules/frida
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    ### The prebuilt TypeScript compiler needs a Nix-compatible ELF interpreter
    autoPatchelf node_modules/@tsrs
  '';

  env = {
    HUSKY = "0";
    DO_NOT_TRACK = "1";
    TURBO_TELEMETRY_DISABLED = "1";
    TURBO_TOKEN = "";
    TURBO_CACHE = "local:rw";
  };

  postInstall =
    let
      ### The Ghidra variant pins the installation and the JDK that satisfies
      ### its declared Java bounds, so the MCP server's installation checks
      ### (version, headless, native decompiler, java) pass without relying on
      ### the ambient environment or on PATH discovery.
      ghidraWiring = withGhidra && ghidra != null;
      runtimePackages =
        extraPackages ++ lib.optional ghidraWiring ghidra ++ lib.optional (ghidraWiring && jdk != null) jdk;
      wrapArgs = [
        "--prefix"
        "PATH"
        ":"
        (lib.makeBinPath runtimePackages)
      ]
      ++ lib.optionals ghidraWiring (
        [
          "--set"
          "GHIDRA_INSTALL_DIR"
          "${ghidra}/lib/ghidra"
        ]
        ++ lib.optionals (jdk != null) [
          "--set"
          "JAVA_HOME"
          "${jdk}/lib/openjdk"
        ]
      );
    in
    lib.optionalString (runtimePackages != [ ]) ''
      for prog in "$out"/bin/*; do
        [ -x "$prog" ] || continue
        wrapProgram "$prog" ${lib.escapeShellArgs wrapArgs}
      done
    '';

  meta = {
    description = "Reverse engineer anything from your terminal or agent with one CLI and MCP server";
    homepage = "https://github.com/morluto/rea";
    license = lib.licenses.mit;
    mainProgram = "rea";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    sourceProvenance = [
      lib.sourceTypes.fromSource
      lib.sourceTypes.binaryNativeCode
    ];
    broken = compatibleNodejs == null;
  };
}
