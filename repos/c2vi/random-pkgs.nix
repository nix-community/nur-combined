{ mypkgs, specialArgs, nixos-generators,
  system, inputs, nixpkgs, self,
  ... 
}:{
  tunefox = mypkgs.firefox-unwrapped.overrideAttrs (final: prev: {
    NIX_CFLAGS_COMPILE = [ (prev.NIX_CFLAGS_COMPILE or "") ] ++ [ "-O3" "-march=native" "-fPIC" ];
    requireSigning = false;
  });

  run-vm = specialArgs.pkgs.writeScriptBin "run-vm" ''
    ${self.nixosConfigurations.hpm.config.system.build.vm}/bin/run-hpm-vm -m 4G -cpu host -smp 4
  '';

  hec-img = nixos-generators.nixosGenerate {
    inherit system;
    modules = [
      ./hosts/hpm.nix
    ];
    format = "raw";
    inherit specialArgs;
  };

  prootTermux = inputs.nix-on-droid.outputs.packages.${system}.prootTermux;

  hello-container = let pkgs = nixpkgs.legacyPackages.${system}.pkgs; in pkgs.dockerTools.buildImage {
    name = "hello";
    tag = "0.1.0";

    config = { Cmd = [ "${pkgs.bash}/bin/bash" ]; };

    created = "now";
  };
}
