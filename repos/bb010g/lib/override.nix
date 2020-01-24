let libExtension = import ./.; in
pkgs: {
  lib = pkgs.lib.extend libExtension;
}
