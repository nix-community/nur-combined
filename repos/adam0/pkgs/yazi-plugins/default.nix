{
  # keep-sorted start
  callPackage,
  lib,
  stdenvNoCC,
  # keep-sorted end
}: let
  inherit
    (builtins)
    # keep-sorted start
    mapAttrs
    readDir
    # keep-sorted end
    ;
  inherit
    (lib)
    # keep-sorted start
    filterAttrs
    pipe
    platforms
    removeSuffix
    # keep-sorted end
    ;

  root = ./.;

  mkYaziPlugin = args @ {
    # keep-sorted start
    installPhase ? null,
    meta ? {},
    pname,
    src,
    # keep-sorted end
    ...
  }: let
    pluginName = removeSuffix ".yazi" pname;
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
            # keep-sorted start
            description = meta.description or "";
            platforms = meta.platforms or platforms.all;
            # keep-sorted end
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
  pipe root [
    readDir
    (filterAttrs (_: type: type == "directory"))
    (mapAttrs (name: _: call name))
  ]
  // {
    inherit mkYaziPlugin;
  }
