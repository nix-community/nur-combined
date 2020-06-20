{ buildGoModule, fetchzip, lib, sources }:
buildGoModule rec {
  name = "efm-langserver";
  version = "0.0.14";
  src = fetchzip { inherit (sources.efm-langserver) url sha256; };
  modSha256 = "0cc55yswyls34s6ryc9r3vlxc90dq5xgm4fz6aynjhw7f48scf46";
  vendorSha256 = "0cc55yswyls34s6ryc9r3vlxc90dq5xgm4fz6aynjhw7f48scf46";
  subPackages = [ "." ];

  meta = with lib; {
    description = "General purpose Language Server";
    homepage = https://github.com/mattn/efm-langserver;
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}
