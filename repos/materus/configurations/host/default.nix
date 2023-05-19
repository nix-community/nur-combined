 {inputs,  materusFlake}:

 let
 profles = import ../profile;
 in
 {
  materusPC = inputs.nixpkgs.lib.nixosSystem rec {
          specialArgs = {inherit inputs; inherit materusFlake;};
          system = "x86_64-linux";
          modules = [
            ./materusPC
            inputs.private.systemModule
            profles.osProfile
          ];
        };

 }