{
  appimageTools,
  common-updater-scripts,
  curl,
  fetchurl,
  jq,
  lib,
  stdenv,
  writeScript,
}:
let
  version = "1.1.1";

  sources = {
    x86_64 = fetchurl {
      url = "https://github.com/BodbDearg/PsyDoom/releases/download/releases%2F${version}/PsyDoom_${version}_Linux_x86_64.AppImage";
      sha256 = "sha256-RtxIEjAtf0Q0UeaavUombaqVlis8aACldelxiemdsYo=";
    };
    aarch64 = fetchurl {
      url = "https://github.com/BodbDearg/PsyDoom/releases/download/releases%2F${version}/PsyDoom_${version}_Linux_AArch64.AppImage";
      sha256 = "sha256-tB2kLokDxlNNjCozW9wtw9cJkKOR6aEN+B+c4olxTew=";
    };
    armhf = fetchurl {
      url = "https://github.com/BodbDearg/PsyDoom/releases/download/releases%2F${version}/PsyDoom_${version}_Linux_ArmHF.AppImage";
      sha256 = "sha256-tB2kLokDxlNNjCozW9wtw9cJkKOR6aEN+B+c4olxTew=";
    };
  };

  sourceMap = with sources; {
    x86_64-linux = x86_64;
    aarch64-linux = aarch64;
    armv6l-linux = armhf;
    armv7a-linux = armhf;
    armv7l-linux = armhf;
  };
in
appimageTools.wrapType2 {
  pname = "psydoom-bin";
  inherit version;
  src = sourceMap.${stdenv.system} or sources.x86_64;

  extraInstallCommands = ''
    mv $out/bin/psydoom-bin $out/bin/psydoom
  '';

  passthru = sources // {
    updateScript = writeScript "update-psydoom-bin" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p curl pcre2 common-updater-scripts jq

      version="$(curl -s https://api.github.com/repos/BodbDearg/PsyDoom/releases/latest | jq -r .name)"
      ${lib.concatMapStringsSep "\n" (
        system:
        ''update-source-version "$UPDATE_NIX_ATTR_PATH" "$version" --source-key=${system} --ignore-same-version''
      ) (builtins.attrNames sources)}
    '';
  };

  meta = {
    description = "A backport of PSX Doom to PC";
    homepage = "https://github.com/BodbDearg/PsyDoom";
    license = lib.licenses.gpl3Plus;
    platforms = builtins.attrNames sourceMap;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "psydoom";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
