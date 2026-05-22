{
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ./lib { inherit pkgs; }) callPackage;

  amcdx-video-patcher-cli = callPackage ./amcdx-video-patcher-cli { };
  binah = callPackage ./binah { };
  cxadc = callPackage ./cxadc { kernel = pkgs.linuxPackages.kernel; };
  cxadc-vhs-server = callPackage ./cxadc-vhs-server { };
  cxadc-vhs-server-jitterbug = callPackage ./cxadc-vhs-server-jitterbug { inherit cxadc-vhs-server; };
  decode-orc = callPackage ./decode-orc {
    inherit ezpwd-reed-solomon;
    nodeeditor = nodeeditor-unstable;
  };
  decode-orc-unstable = callPackage ./decode-orc-unstable { inherit decode-orc; };
  domesdayduplicator = callPackage ./domesdayduplicator { };
  ezpwd-reed-solomon = callPackage ./ezpwd-reed-solomon { };
  hsdaoh = callPackage ./hsdaoh { };
  hsdaoh-misrc = callPackage ./hsdaoh-misrc { inherit hsdaoh; };
  hsdaoh-misrc-unstable = callPackage ./hsdaoh-misrc-unstable { inherit hsdaoh; };
  ld-decode = callPackage ./ld-decode { };
  ld-decode-tools = callPackage ./ld-decode-tools { inherit ezpwd-reed-solomon; };
  ld-decode-unstable = callPackage ./ld-decode-unstable { inherit ld-decode; };
  ltfs = callPackage ./ltfs { };
  misrc-tools = callPackage ./misrc-tools { hsdaoh = hsdaoh-misrc; };
  misrc-tools-unstable = callPackage ./misrc-tools-unstable {
    inherit misrc-tools;
    hsdaoh = hsdaoh-misrc-unstable;
  };
  nodeeditor = callPackage ./nodeeditor { };
  nodeeditor-unstable = callPackage ./nodeeditor-unstable { inherit nodeeditor; };
  stfs = callPackage ./stfs { };
  tbc-raw-stack = callPackage ./tbc-raw-stack { };
  tbc-tools = callPackage ./tbc-tools {
    inherit ezpwd-reed-solomon;
    cudaSupport = false;
  };
  tbc-tools-unstable = callPackage ./tbc-tools-unstable {
    inherit tbc-tools;
    cudaSupport = false;
  };
  tbc-video-export = callPackage ./tbc-video-export { };
  vapoursynth-analog = callPackage ./vapoursynth-analog { };
  vapoursynth-bwdif = callPackage ./vapoursynth-bwdif { };
  vapoursynth-neofft3d = callPackage ./vapoursynth-neofft3d { };
  vapoursynth-vsrawsource = callPackage ./vapoursynth-vsrawsource { };
  vhs-decode = callPackage ./vhs-decode { };
  vhs-decode-auto-audio-align = callPackage ./vhs-decode-auto-audio-align { inherit binah; };
  vhs-decode-unstable = callPackage ./vhs-decode-unstable { inherit vhs-decode; };
in
{
  inherit
    amcdx-video-patcher-cli
    binah
    cxadc
    cxadc-vhs-server
    cxadc-vhs-server-jitterbug
    decode-orc
    decode-orc-unstable
    domesdayduplicator
    ezpwd-reed-solomon
    hsdaoh
    hsdaoh-misrc
    hsdaoh-misrc-unstable
    ld-decode
    ld-decode-tools
    ld-decode-unstable
    ltfs
    misrc-tools
    misrc-tools-unstable
    nodeeditor
    nodeeditor-unstable
    stfs
    tbc-raw-stack
    tbc-tools
    tbc-tools-unstable
    tbc-video-export
    vapoursynth-analog
    vapoursynth-bwdif
    vapoursynth-neofft3d
    vapoursynth-vsrawsource
    vhs-decode
    vhs-decode-auto-audio-align
    vhs-decode-unstable
    ;
}
