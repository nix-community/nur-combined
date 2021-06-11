{ stdenv
, abc-verifier
, fetchFromGitHub
, yosys
}:

let
  localAbc-verifier = abc-verifier.overrideAttrs (_: rec {
    pname = "abc-verifier";
    version = "2020.06.22";

    src = fetchFromGitHub {
      owner  = "YosysHQ";
      repo   = "abc";
      rev    = "341db25668f3054c87aa3372c794e180f629af5d";
      sha256 = "14cgv34vz5ljkcms6nrv19vqws2hs8bgjgffk5q03cbxnm2jxv5s";
    };

    passthru.rev = src.rev;
  });
in

(yosys.overrideAttrs (oldAttrs: rec {
  pname   = "symbiflow-yosys";
  version = "0.9+3683";

  src = fetchFromGitHub {
    owner  = "SymbiFlow";
    repo   = "yosys";
    rev    = "b7d46be40d538f66309fc1d53a618a7fdfcdb8c8";
    sha256 = "0afdsvyds1ypd31kxymrjdz4ys83i670iriczbglaa5l5gp9nzgg";
  };
})).override {
  abc-verifier = localAbc-verifier;
}
