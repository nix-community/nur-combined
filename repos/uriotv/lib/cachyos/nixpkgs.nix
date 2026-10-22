# Deliberately independent of the repository/consumer nixpkgs. Moving this pin
# changes the kernel/toolchain derivations and requires a reviewed cache rebuild.
let
  pin = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
  source = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${pin.rev}.tar.gz";
    sha256 = pin.narHash;
  };
in
import source {
  system = "x86_64-linux";
}
