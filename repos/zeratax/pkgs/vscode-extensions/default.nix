{ callPackage, vscode-utils, lib }:
let inherit (vscode-utils) buildVscodeMarketplaceExtension;

in {
  b4dm4n.nixpkgs-fmt = callPackage ./nixpkgs-fmt { };

  hookyqr.beautify = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "beautify";
      publisher = "HookyQR";
      version = "1.5.0";
      sha256 = "1c0kfavdwgwham92xrh0gnyxkrl9qlkpv39l1yhrldn8vd10fj5i";
    };
    meta = with lib; {
      license = licenses.mit;
      maintainers = [ maintainers.zeratax ];
    };
  };

  crystal-lang-tools.crystal-lang = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "crystal-lang";
      publisher = "crystal-lang-tools";
      version = "0.8.1";
      sha256 = "00d6wmp873nc44cq6qxsnrg0jk4h63jp5d4bjzqqdy2q1af1dg74";
    };
    meta = with lib; {
      license = licenses.mit;
      maintainers = [ maintainers.zeratax ];
    };
  };

  eamodio.gitlens = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "gitlens";
      publisher = "eamodio";
      version = "11.1.0";
      sha256 = "1g8ayhsfq6yzbbrvffsdqgms3nsijd5x0x13vdldfqsp6yfkh0f1";
    };
    meta = with lib; {
      license = licenses.mit;
      maintainers = [ maintainers.zeratax ];
    };
  };

  github.copilot = buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "copilot";
      publisher = "GitHub";
      version = "1.155.679";
      sha256 = "sha256-dmjob5JIiUt/kWurxU2FgyGXHUm9qLL3SbdDDk8NIGA=";
    };
    meta = with lib; {
      license = licenses.unfree; # i think, i can at least not find one
      maintainers = [ maintainers.zeratax ];
    };
  };
}
