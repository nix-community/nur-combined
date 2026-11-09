{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchurl,
  nodejs_26,
  autoPatchelfHook,
  makeWrapper,
  stdenv,
  procps,
  python3,
  writeShellApplication,
  nix-update,
  nix,
  nixfmt,
  curl,
  jq,
  coreutils,
  git,
}:

let
  frida = lib.importJSON ./frida.json;
  fridaArch =
    {
      x86_64-linux = "x64";
      aarch64-linux = "arm64";
    }
    .${stdenv.hostPlatform.system};
  fridaBinding = fetchurl {
    url = "https://github.com/frida/frida/releases/download/${frida.version}/frida-v${frida.version}-napi-v${toString frida.napiVersion}-linux-${fridaArch}.tar.gz";
    hash = frida.hashes.${stdenv.hostPlatform.system};
  };
in
buildNpmPackage (finalAttrs: {
  pname = "rea";
  version = "6.8.0";

  src = fetchFromGitHub {
    owner = "morluto";
    repo = "rea";
    # Keep the revision identical to the release tag returned by nix-update.
    # Using `tag` adds refs/tags/ and makes prefixed releases look changed daily.
    rev = "rea-agents-${finalAttrs.version}";
    hash = "sha256-2ADn3U3lvUoB4tCEpzO0rMfYE4sis+5uBiEazcp0gpI=";
  };

  npmDepsHash = "sha256-3WPXD+qm5WVfrTEvepKwX5RZBfbLBcPB0uDmKIx4MR8=";
  nodejs = nodejs_26;
  # Install the matching, hash-pinned Frida binding ourselves instead of letting
  # its lifecycle script download it from the network inside the build.
  npmFlags = [ "--ignore-scripts" ];
  env.HUSKY = "0";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ];

  preBuild = ''
    test "$(node -p 'require("./node_modules/frida/package.json").version')" = "${frida.version}"
    tar -xzf ${fridaBinding} -C node_modules/frida
    # npm installs both libc variants on Linux; only the glibc build is used.
    find node_modules -type d -name '*-musl' -prune -exec rm -rf {} +
    autoPatchelf node_modules
  '';

  postInstall = ''
    for command in rea rea-agents; do
      wrapProgram "$out/bin/$command" \
        --prefix PATH : ${lib.makeBinPath [ procps ]}
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ python3 ];
  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/rea-check-home"
    mkdir -p "$HOME"
    test "$("$out/bin/rea" --version)" = "${finalAttrs.version}"
    "$out/bin/rea" --help > /dev/null
    # Loading this addon catches unresolved shared libraries and Node ABI drift.
    node -e 'require(process.argv[1])' \
      "$out/lib/node_modules/rea-agents/node_modules/@lydell/node-pty"
    node --input-type=module -e '
      const frida = await import(process.argv[1]);
      const device = await frida.getLocalDevice();
      const processes = await device.enumerateProcesses();
      if (!processes.some(p => p.pid === process.pid)) {
        throw new Error("Frida could not enumerate its own process");
      }
      console.log("Frida local device and process enumeration passed");
    ' "$out/lib/node_modules/rea-agents/node_modules/frida/build/src/frida.js"
    python3 ${./check-mcp.py} "$out/bin/rea"
    runHook postInstallCheck
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "update-rea";
    runtimeInputs = [
      python3
      nix-update
      nix
      nixfmt
      curl
      jq
      coreutils
      git
    ];
    text = ''
      exec ${python3}/bin/python3 ${./../../../maintainers/update.py} rea
    '';
  });

  meta = {
    description = "Reverse engineering CLI and MCP server for agents";
    homepage = "https://github.com/morluto/rea";
    changelog = "https://github.com/morluto/rea/releases/tag/rea-agents-${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "rea";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
