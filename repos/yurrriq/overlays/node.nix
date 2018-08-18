self: super: rec {

  nodejs = super.nodejs-8_x;

  nodePackages = super.nodePackages //
    super.callPackage ../pkgs/development/node-packages {
      inherit (super) pkgs;
      inherit nodejs;
    };

}
