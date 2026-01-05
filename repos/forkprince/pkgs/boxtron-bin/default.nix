{
  soundfont-fluid,
  dosbox-staging,
  inotify-tools,
  stdenvNoCC,
  fetchzip,
  timidity,
  lib,
}: let
  ver = lib.helper.read ./version.json;
in
  stdenvNoCC.mkDerivation rec {
    pname = "boxtron-bin";
    inherit (ver) version;

    nativeBuildInputs = [
      soundfont-fluid
      dosbox-staging
      inotify-tools
      timidity
    ];

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
      sed -i 's|# cmd = ~/projects/dosbox/src/dosbox|cmd = ${dosbox-staging}/bin/dosbox|g' $steamcompattool/settings.py
    '';

    meta = {
      description = ''
        Steam Play compatibility tool to run DOS games using native Linux DOSBox

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://github.com/dreamer/boxtron";
      license = lib.licenses.gpl2Only;
      maintainers = ["Prinky"];
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
