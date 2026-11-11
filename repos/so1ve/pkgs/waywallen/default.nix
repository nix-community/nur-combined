{
  appimageTools,
  callPackage,
  lib,
  unzip,
  source ? callPackage ./source.nix { },
  plugins ? [ ],
}:

let
  pname = "waywallen";
  inherit (source) version src;

  appId = "org.waywallen.waywallen";
  availablePlugins = lib.mapAttrs (
    name: metadata:
    (callPackage (./plugins + "/${name}.nix") { })
    // {
      inherit (metadata) id;
      license = lib.licenses.${metadata.license};
    }
  ) (lib.importJSON ./plugins/catalog.json);

  selectedPlugins = map (
    plugin:
    if builtins.isString plugin then
      availablePlugins.${plugin} or (throw "waywallen: unknown plugin ${plugin}")
    else
      plugin
  ) plugins;

  installPlugin =
    { id, src, ... }:
    ''
      pluginDir="$out/usr/share/waywallen/plugins/"${lib.escapeShellArg id}
      mkdir -p "$pluginDir"
      ${lib.getExe unzip} -q ${lib.escapeShellArg src} -d "$pluginDir"
      test -f "$pluginDir/plugin.toml"
      chmod -R a+rX "$pluginDir"
    '';

  contents = appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      # The upstream AppImage ships directories with mode 0700.
      chmod -R a+rX "$out"
    ''
    + lib.concatMapStrings installPlugin selectedPlugins;
  };
in

assert lib.assertMsg (lib.allUnique (
  map (plugin: plugin.id) selectedPlugins
)) "waywallen: duplicate plugin IDs";

appimageTools.wrapAppImage {
  inherit pname version contents;

  # The Open Wallpaper Engine scene renderer links against liblz4.so.1.
  extraPkgs = pkgs: [ pkgs.lz4.lib ];

  extraInstallCommands = ''
    install -Dm444 "${contents}/usr/share/applications/${appId}.desktop" \
      "$out/share/applications/${appId}.desktop"
    install -Dm444 "${contents}/usr/share/icons/hicolor/scalable/apps/${appId}.svg" \
      "$out/share/icons/hicolor/scalable/apps/${appId}.svg"
  '';

  passthru = { inherit availablePlugins; };

  meta = {
    description = "Dynamic wallpaper manager for Linux";
    homepage = "https://github.com/waywallen/waywallen";
    changelog = "https://github.com/waywallen/waywallen/releases/tag/v${version}";
    license = [
      lib.licenses.mit
    ]
    ++ lib.concatMap (plugin: lib.toList (plugin.license or [ ])) selectedPlugins;
    mainProgram = pname;
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
