{
  pkgs,
  fetchFromGitHub,
  writeTextFile,
}:
let
  cvc5 = pkgs.cvc5.overrideAttrs (_: {
    version = "1.3.4";
    src = fetchFromGitHub {
      owner = "cvc5";
      repo = "cvc5";
      tag = "cvc5-1.3.4";
      hash = "sha256-PZcOArSTyJzyd2DKT8K0aFC4RlVXgTCnkoU0f08KPfY=";
    };

    passthru.settings = writeTextFile {
      name = "cvc5-settings";
      text = ''
        CVC5_HOME=${cvc5}
        CVC5_VERSION=1.3.4
        CVC5_SOLVER=${cvc5}/bin/cvc5
        CVC5_INSTALLED=yes
      '';
      destination = "/etc/settings";
    };
  });
in
cvc5
