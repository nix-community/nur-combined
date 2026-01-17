{
  lib,
  callPackage,
  stdenvNoCC,
}: let
  root = ./.;

  mkYaziPlugin = args @ {
    pname,
    src,
    meta ? {},
    installPhase ? null,
    ...
  }: let
    pluginName = lib.removeSuffix ".yazi" pname;
  in
    stdenvNoCC.mkDerivation (
      args
      // {
        installPhase =
          if installPhase != null
          then installPhase
          else if (src ? owner && src.owner == "yazi-rs")
          then ''
            runHook preInstall

            cp -r ${pname} $out
            rm $out/LICENSE
            cp LICENSE $out

            runHook postInstall
          ''
          else ''
            runHook preInstall

            cp -r . $out

            runHook postInstall
          '';
        meta =
          meta
          // {
            description = meta.description or "";
            platforms = meta.platforms or lib.platforms.all;
            homepage =
              if (src ? owner && src.owner == "yazi-rs")
              then "https://github.com/yazi-rs/plugins/tree/main/${pname}"
              else meta.homepage or null;
          };
        passthru =
          (args.passthru or {})
          // {
            inherit pluginName;
          };
      }
    );

  call = name: callPackage (root + "/${name}") {inherit mkYaziPlugin;};
in
  lib.pipe root [
    builtins.readDir
    (lib.filterAttrs (_: type: type == "directory"))
    (builtins.mapAttrs (name: _: call name))
  ]
  // {
    inherit mkYaziPlugin;
  }
