self: super: {

  nodejs = super.nodejs-8_x;

  nodePackages = self.nodePackages //
    super.callPackage ./pkgs/development/node-packages {
      inherit pkgs;
      inherit nodejs;
    };


}
