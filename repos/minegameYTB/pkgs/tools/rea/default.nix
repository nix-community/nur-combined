{
  lib,
  stdenv,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  nodejs_22 ? null,
  nodejs_24 ? null,
  nodejs_26 ? null,
  ghidra ? null,
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
  version = "6.8.0";

  src = fetchFromGitHub {
    owner = "morluto";
    repo = "rea";
    rev = "rea-agents-${version}";
    hash = "sha256-2ADn3U3lvUoB4tCEpzO0rMfYE4sis+5uBiEazcp0gpI=";
  };

  ### REA requires ^22.23.4 || ^24.22.1 || >=26.12.1
  compatibleNodejs =
    let
      versionAtLeast = lib.versionAtLeast or (a: b: (builtins.compareVersions a b) >= 0);
      isCompatible = n:
        n != null
        && (
          (lib.hasPrefix "26." n.version && versionAtLeast n.version "26.12.1")
          || (lib.hasPrefix "24." n.version && versionAtLeast n.version "24.22.1")
          || (lib.hasPrefix "22." n.version && versionAtLeast n.version "22.23.4")
        );
      candidates = builtins.filter isCompatible [ nodejs_26 nodejs_24 nodejs_22 ];
    in
      if candidates == [ ] then null else builtins.head candidates;

  nodejs = if compatibleNodejs != null then compatibleNodejs else nodejs_26;
  npmDepsHash = "sha256-3WPXD+qm5WVfrTEvepKwX5RZBfbLBcPB0uDmKIx4MR8=";

  ### Build the same way as the upstream CI (Turbo compile + generated skills)
  npmBuildScript = "build:cached";

  ### Native install scripts cannot download prebuilt binaries in the sandbox
  npmRebuildFlags = [ "--ignore-scripts" ];

  nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
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
      runtimePackages =
        extraPackages
        ++ lib.optional (withGhidra && ghidra != null) ghidra;
    in
    lib.optionalString (runtimePackages != [ ]) ''
      for prog in "$out"/bin/*; do
        [ -x "$prog" ] || continue
        wrapProgram "$prog" \
          --prefix PATH : ${lib.makeBinPath runtimePackages}
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
