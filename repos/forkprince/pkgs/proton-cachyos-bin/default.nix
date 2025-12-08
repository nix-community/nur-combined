{
  type ? "v1",
  stdenvNoCC,
  fetchzip,
  lib,
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);

  platform = lib.getAttr type info.platforms;

  display = "Proton-CachyOS-${type}";
in
  stdenvNoCC.mkDerivation rec {
    pname = "proton-cachyos-${type}-bin";
    inherit (info) version;

    src = fetchzip {
      url = "https://github.com/${info.repo}/releases/download/${version}/${builtins.replaceStrings ["{version}"] [version] platform.file}";
      inherit (platform) hash;
      stripRoot = false;
    };

    dontConfigure = true;
    dontBuild = true;

    outputs = [
      "out"
      "steamcompattool"
    ];

    installPhase = ''
      runHook preInstall

      # Make it impossible to add to an environment. You should use the appropriate NixOS option.
      # Also leave some breadcrumbs in the file.
      echo "${pname} should not be installed into environments. Please use programs.steam.extraCompatPackages instead." > $out

      mkdir $steamcompattool
      ln -s $src/* $steamcompattool
      rm $steamcompattool/compatibilitytool.vdf
      cp $src/compatibilitytool.vdf $steamcompattool

      runHook postInstall
    '';

    preFixup = ''
      substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
        --replace-fail "${version}" "${display}"
    '';

    meta = {
      description = ''
        Compatibility tool for Steam Play based on Wine and additional components

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://github.com/CachyOS/proton-cachyos";
      license = lib.licenses.bsd3;
      maintainers = ["Prinky"];
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
