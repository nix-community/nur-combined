{
  lib,
  stdenvNoCC,
  python3,
  nodejs_24,
  darwin,
  writeShellScriptBin,
  fetchzip,
  antigravity-cli,
  source,
  unlockContext ? stdenvNoCC.hostPlatform.isDarwin,
  prompts ? {},
}: let
  pins = builtins.fromJSON (builtins.readFile ./pins.json);
  promptPatcher = fetchzip {
    url = "https://codeload.github.com/lbyxiaolizi/agy-context/tar.gz/${pins.commit}";
    inherit (pins) hash;
    extension = "tar.gz";
  };
  # The patcher probes running processes and uses Apple's codesign before the final sigtool signature
  pgrep = writeShellScriptBin "pgrep" "exit 1";
  codesign = writeShellScriptBin "codesign" "exit 0";
in
  stdenvNoCC.mkDerivation {
    pname = "antigravity-cli-modified";
    version = antigravity-cli.version;

    dontUnpack = true;
    dontBuild = true;
    nativeBuildInputs = lib.optional stdenvNoCC.hostPlatform.isDarwin darwin.sigtool;

    installPhase = ''
      runHook preInstall

      install -Dm755 ${antigravity-cli}/bin/agy $out/bin/agy
      ${lib.optionalString unlockContext ''
        PATH=${lib.makeBinPath [pgrep codesign]}:$PATH ${lib.getExe python3} ${source.src}/scripts/agy-patch.py --binary $out/bin/agy --limit 0 --in-place --no-backup --no-env-fix
      ''}
      ${lib.optionalString (prompts != {}) ''
        ${lib.getExe nodejs_24} --input-type=module -e '
          import { readFileSync, writeFileSync } from "node:fs";
          import { patchBinary } from "${promptPatcher}/scripts/binary-patcher.mjs";
          const templates = Object.fromEntries(Object.entries(JSON.parse(process.argv[2])).map(([name, path]) => [name, readFileSync(path, "utf8")]));
          writeFileSync(process.argv[1], patchBinary(readFileSync(process.argv[1]), { templates }));
        ' "$out/bin/agy" ${lib.escapeShellArg (builtins.toJSON (lib.mapAttrs (_: path: "${path}") prompts))}
      ''}
      ${lib.optionalString stdenvNoCC.hostPlatform.isDarwin ''
        codesign --force --sign - --identifier cli --options runtime $out/bin/agy
      ''}

      runHook postInstall
    '';

    meta =
      antigravity-cli.meta
      // {
        description = "Antigravity CLI with its context clamp lifted and built-in prompts replaceable";
        mainProgram = "agy";
        maintainers = [{name = "mzwing";}];
      };
  }
