{
  lib,
  fetchFromGitHub,
  stdenvNoCC,
}: let
  mkYaziPlugin = args @ {
    pname,
    src,
    meta ? {},
    installPhase ? null,
    ...
  }: let
    # Extract the plugin name from pname (removing .yazi suffix if present)
    pluginName = lib.removeSuffix ".yazi" pname;
  in
    stdenvNoCC.mkDerivation (
      args
      // {
        installPhase =
          if installPhase != null
          then installPhase
          else if (src ? owner && src.owner == "yazi-rs")
          then
            # NOTE: License is a relative symbolic link
            # We remove the link and copy the true license
            ''
              runHook preInstall

              cp -r ${pname} $out
              rm $out/LICENSE
              cp LICENSE $out

              runHook postInstall
            ''
          else
            # Normal plugins don't require special installation other than to copy their contents.
            ''
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
      }
    );
in
  mkYaziPlugin {
    pname = "snapshots-yazi";
    version = "0-unstable-2026-01-03";

    src = fetchFromGitHub {
      owner = "Mikilio";
      repo = "snapshots.yazi";
      rev = "408dc3da3e0d90fcf55aa042292fdc8c80b924a9";
      hash = "";
    };

    meta = {
      description = " Visit past snapshots of your current directory in Yazi";
      homepage = "https://github.com/mikilio/snapshots.yazi";
      license = lib.licenses.mit;
    };
  }
