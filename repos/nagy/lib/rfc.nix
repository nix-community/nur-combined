{
  pkgs,
  lib ? pkgs.lib,
}:

{
  fetchRFCBulk =
    { range, hash, ... }@args:
    pkgs.fetchzip (
      {
        url = "https://www.rfc-editor.org/in-notes/tar/RFCs${range}.tar.gz";
        inherit hash;
        stripRoot = false;
      }
      // (lib.removeAttrs args [ "range" ])
    );
}
