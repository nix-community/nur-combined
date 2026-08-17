{ lib, ... }:
let
  # Fetched during evaluation via builtins.fetchTarball, so no build-time
  # derivation dependency. Hash verified for the referenced commit.
  rioThemeSrc = builtins.fetchTarball {
    url = "https://github.com/catppuccin/rio/archive/4d37b8334a3e8f853fc6543dc2a60c295a66ddca.tar.gz";
    sha256 = "sha256-AzZmRLHptgQB3CC1fl/E9BR1Qw5a6VPprpQopn/O3CM=";
  };
  starshipThemeSrc = builtins.fetchTarball {
    url = "https://github.com/catppuccin/starship/archive/5906cc369dd8207e063c0e6e2d27bd0c0b567cb8.tar.gz";
    sha256 = "sha256-FLHjbClpTqaK4n2qmepCPkb8rocaAo3qeV4Zp1hia0g=";
  };
in
{
  catppuccin = {
    enable = lib.mkDefault true;
    autoEnable = lib.mkDefault true;
    flavor = lib.mkDefault "frappe";
    accent = lib.mkDefault "red";
    # Avoid IFD: upstream module imports the theme TOML from the
    # whiskers-built package at eval time, which cannot be built when
    # evaluating for a foreign platform (CI evaluates darwin configs
    # on x86_64-linux). Use the raw port source instead.
    sources.starship = lib.mkDefault "${starshipThemeSrc}/themes";
    sources.rio = lib.mkDefault "${rioThemeSrc}/themes";
  };
}
