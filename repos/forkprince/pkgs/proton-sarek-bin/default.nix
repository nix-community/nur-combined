{
  steamDisplayName ? "Proton-Sarek",
  stdenvNoCC,
  fetchzip,
  lib,
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);
in
  stdenvNoCC.mkDerivation rec {
    pname = "proton-sarek-bin";
    inherit (info) version;

    src = fetchzip {
      url = "https://github.com/${info.repo}/releases/download/${version}/${version}.tar.gz";
      inherit (info) hash;
    };

    dontUnpack = true;
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
        --replace-fail "${version}" "${steamDisplayName}"
    '';

    meta = {
      description = ''
        Compatibility tool for Steam Play based on Wine and additional components, with a focus on older PCs

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://github.com/pythonlover02/Proton-Sarek";
      license = lib.licenses.bsd3;
      maintainers = ["Prinky"];
      platforms = ["x86_64-linux"];
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
