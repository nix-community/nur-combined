{
  pkgs,
  sources,
  utils,
  variants ? ["osirus" "ostirus" "vavra" "xenia" "nodalred2x"],
  buildFx ? true,
  ...
}:
utils.juce.mkJucePackage {
  inherit (sources.dsp56300) pname version src;

  postPatch = ''
    substituteAll CMakeLists.txt --replace-fail "/usr/local" "${placeholder "out"}"
  '';

  cmakeFlags = let
    enable = name: cond: "gearmulator_${pkgs.lib.toUpper name}=${
      if cond
      then "on"
      else "off"
    }";
  in
    (map (v: enable "SYNTH_${v}" true) variants)
    ++ [
      (enable "BUILD_FX_PLUGIN" buildFx)
      (enable "BUILD_JUCEPLUGIN_LV2" true)
    ];

  dontUseJuceInstall = true;

  meta = with pkgs.lib; {
    description = "Emulation of classic VA synths of the late 90s/2000s that are based on Motorola 56300 family DSPs (${pkgs.lib.concatStringsSep ", " variants})";
    homepage = "https://dsp56300.wordpress.com/";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
