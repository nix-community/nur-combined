{
  steamDisplayName ? "Boxtron",
  soundfont-fluid,
  dosbox-staging,
  inotify-tools,
  stdenvNoCC,
  fetchzip,
  timidity,
  lib,
}: let
  info = builtins.fromJSON (builtins.readFile ./info.json);
in
  stdenvNoCC.mkDerivation rec {
    pname = "boxtron-bin";
    inherit (info) version;

    nativeBuildInputs = [
      soundfont-fluid
      dosbox-staging
      inotify-tools
      timidity
    ];

    src = fetchzip {
      url = "https://github.com/${info.repo}/releases/download/v${version}/boxtron.tar.xz";
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
        Steam Play compatibility tool to run DOS games using native Linux DOSBox

        (This is intended for use in the `programs.steam.extraCompatPackages` option only.)
      '';
      homepage = "https://github.com/dreamer/boxtron";
      license = lib.licenses.gpl2Only;
      maintainers = ["Prinky"];
      platforms = ["x86_64-linux"];
      broken = true;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
