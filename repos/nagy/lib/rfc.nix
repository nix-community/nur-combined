{
  pkgs,
  fetchzip ? pkgs.fetchzip,
}:

{
  fetchRFCBulk =
    { range, ... }@args:
    fetchzip (
      {
        url = "https://www.rfc-editor.org/in-notes/tar/RFCs${range}.tar.gz";
        stripRoot = false;
      }
      // (builtins.removeAttrs args [ "range" ])
    );
}
