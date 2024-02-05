{ nvsrcs, appimageTools }:
appimageTools.wrapType2 {
  name = "enso";
  inherit (nvsrcs.enso) src version;
}
