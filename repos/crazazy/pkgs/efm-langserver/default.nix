{ buildGoModule, fetchzip, lib, sources }:
buildGoModule rec {
  name = "efm-langserver";
  version = "0.0.14";
  src = fetchzip { inherit (sources.efm-langserver) url sha256; };
  modSha256 = vendorSha256;
  vendorSha256 = "1whifjmdl72kkcb22h9b1zadsrc80prrjiyvyba2n5vb4kavximm";
  subPackages = [ "." ];

  meta = with lib; {
    description = "General purpose Language Server";
    homepage = https://github.com/mattn/efm-langserver;
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
