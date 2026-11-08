let
    flake = import ./flake.nix;
    inputs = import ./.tack;
    outputs = flake.outputs {
        self = outputs // {
            lastModifiedDate = inputs.nixpkgs.lastModifiedDate;
        };
    };
in
outputs
