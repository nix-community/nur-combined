self: super:
let
  bcl_proto = self.fetchurl {
    url = "https://github.com/mdavid/protobuf-net/raw/414080ad8464c6afdc954115b9c801f43d87d577/Tools/bcl.proto";
    hash = "sha256-bRToEIISrd4rYjmOZMN3wuTgbbI8bt2OBuRojBjXcLY=";
  };
  datestr = self.depotdownloader-src.lastModifiedDate;
  y = builtins.substring 0 4 datestr;
  m = builtins.substring 4 2 datestr;
  d = builtins.substring 6 2 datestr;
in
{
  depotdownloader = super.depotdownloader.overrideAttrs (oldAttrs: {
    version = "3.4.0-unstable-${y}-${m}-${d}";
    src = self.depotdownloader-src;

    postFixup = (oldAttrs.postFixup or "") + ''
      mkdir -p $out/include/depotdownloader/proto/protobuf-net
      $out/bin/DepotDownloader --export-proto > $out/include/depotdownloader/proto/DepotDownloader.proto
      cp ${bcl_proto} $out/include/depotdownloader/proto/protobuf-net/bcl.proto  
    '';
  });
}
