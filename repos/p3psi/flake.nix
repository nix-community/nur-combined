{
  description = "P3psi's nur";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }: {

    overlay = final: prev:
      let p = rec {
            linux_gru_4_4 = prev.callPackage ./pkgs/linux_gru_4_4 {  };
            linuxPackages_gru_4_4 = final.linuxPackagesFor final.linux_gru_4_4;

            stm8flash = prev.callPackage ./pkgs/stm8flash {  };
          }; in p // { colePackages = p; };
  };
}
