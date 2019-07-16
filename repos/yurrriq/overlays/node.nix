self: super: rec {

  nodejs = super.nodejs-8_x;

  nodePackages = let _nodePackages = super.callPackage ../pkgs/development/node-packages {
    inherit (super) pkgs;
    inherit nodejs;
  }; in super.nodePackages // _nodePackages // {
    aws-azure-login = _nodePackages.aws-azure-login.override {
      PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "true";

      buildInputs = [ super.pkgs.makeWrapper ];
      postInstall = ''
        wrapProgram "$out/bin/aws-azure-login" --set PUPPETEER_EXECUTABLE_PATH "${super.pkgs.chromium}/bin/chromium"
      '';
    };
  };

}
