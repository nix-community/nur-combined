{
  pkgs,
  callPackage',
  ...
}: rec {
  commonBuildInputs = with pkgs; [
    (callPackage' ../pkgs/curl-gnutls3)
    alsa-lib
    fontconfig
    freetype
    libGL
    xorg.libX11
    xorg.libXcursor
    xorg.libXext
    xorg.libXinerama
    xorg.libXrandr
  ];

  mkJucePackage = args @ {
    nativeBuildInputs ? [],
    buildInputs ? [],
    cmakeFlags ? [],
    dontUseJuceInstall ? false,
    ...
  }: let
    stdenv = pkgs.stdenvAdapters.useMoldLinker pkgs.stdenv;
  in
    stdenv.mkDerivation ({
        nativeBuildInputs = with pkgs;
          [
            cmake
            pkg-config
          ]
          ++ nativeBuildInputs;

        buildInputs = commonBuildInputs ++ buildInputs;

        cmakeFlags = ["-DCOPY_PLUGIN_AFTER_BUILD=FALSE"] ++ cmakeFlags;

        postPatch = ''
          for f in $(find -name CMakeLists.txt); do
            substituteInPlace "$f" --replace-quiet "COPY_PLUGIN_AFTER_BUILD TRUE" "COPY_PLUGIN_AFTER_BUILD FALSE"
          done
        '';

        installPhase =
          if dontUseJuceInstall
          then null
          else ''
            for f in *_artefacts/Release/Standalone/*; do
              mkdir -p $out/bin
              cp "$f" $out/bin
            done

            for f in *_artefacts/Release/CLAP/*; do
              mkdir -p $out/lib/clap
              cp "$f" $out/lib/clap
            done

            for f in *_artefacts/Release/LV2/*; do
              mkdir -p $out/lib/lv2
              cp -r "$f" $out/lib/lv2
            done

            for f in *_artefacts/Release/VST3/*; do
              mkdir -p $out/lib/vst3
              cp -r "$f" $out/lib/vst3
            done
          '';
      }
      // (pkgs.lib.removeAttrs args ["nativeBuildInputs" "buildInputs" "cmakeFlags"]));
}
