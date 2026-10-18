{
  lib,
  stdenvNoCC,
  concatTextFile,
  writeShellApplication,
  dsh,
  plugins,
}:
if plugins == [ ] then
  dsh
else
  let
    pluginPatches = map (
      plugin:
      plugin.passthru.pluginPatch
        or (throw "dsh.withPlugins: ${plugin.name} does not expose passthru.pluginPatch")
    ) plugins;

    patch = concatTextFile {
      name = "dsh-with-plugins.cordis.patch.yml";
      files = pluginPatches;
    };

    wrapper = writeShellApplication {
      name = "dsh";
      text = ''
        if [ "''${1:-}" = "plugin" ]; then
          exec ${lib.getExe dsh} "$@"
        fi
        if [ "''${1:-}" = "" ] || [ "''${1#-}" != "''${1}" ]; then
          exec ${lib.getExe dsh} --patch ${patch} "$@"
        fi
        booted_profile=$1
        shift
        exec ${lib.getExe dsh} "$booted_profile" --patch ${patch} "$@"
      '';
    };
  in
  stdenvNoCC.mkDerivation {
    pname = "${dsh.pname}-with-plugins";
    inherit (dsh) version;

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      ln -s ${lib.getExe wrapper} $out/bin/dsh
      runHook postInstall
    '';

    passthru = {
      inherit dsh patch plugins;
    };

    meta = dsh.meta // {
      mainProgram = "dsh";
    };
  }
