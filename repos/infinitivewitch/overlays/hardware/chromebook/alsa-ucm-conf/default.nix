_final: prev:
let
  version = "a4046df34d7f58693590ede2945fe9a38bcbc3e6";
in
{
  alsa-ucm-conf = prev.alsa-ucm-conf.overrideAttrs (_oldAttrs: rec {
    postFixup =
      let
        audio-scripts = prev.fetchzip {
          url = "https://github.com/eupnea-linux/audio-scripts/archive/${version}.zip";
          sha256 = "sha256-IrSX2I/omrchqrFuP060/BEAdM63/O3/zRtXrQ/QLLA=";
        };
      in
      ''
        cp -r ${audio-scripts}/configs/audio/sof/ucms/tgl/sof-rt5682 $out/share/alsa/ucm2/conf.d/
        cp -r ${audio-scripts}/configs/audio/sof/ucms/dmic-common $out/share/alsa/ucm2/conf.d/
        cp -r ${audio-scripts}/configs/audio/sof/ucms/hdmi-common $out/share/alsa/ucm2/conf.d/
      '';
  });
}
