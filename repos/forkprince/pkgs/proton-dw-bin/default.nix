{
  steamDisplayName ? "dwproton",
  stdenvNoCC,
  fetchzip,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation rec {
    pname = "proton-dw-bin";
    inherit (ver) version;

    src = fetchzip (lib.helper.getSingle ver);

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
        --replace-fail "${version}-x86_64" "${steamDisplayName}"
    '';

    meta = {
      description = ''
        Proton builds with the latest Dawn Winery fixes :xdd:

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://dawn.wine/dawn-winery/dwproton";
      license = lib.licenses.bsd3;
      maintainers = ["Prinky"];
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
