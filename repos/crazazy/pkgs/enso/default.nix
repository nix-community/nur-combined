{ nvsrcs, appimageTools }:
appimageTools.wrapType2 {
  pname = "enso";
  inherit (nvsrcs.enso) src version;
}
