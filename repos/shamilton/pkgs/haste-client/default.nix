{ lib
, bundlerEnv
, buildRubyGem
, ruby
}:

let 
  version = "0.2.3";
  deps = bundlerEnv rec {
    name = "haste-client-${version}";
    inherit ruby;
    gemdir = ./.;
  };
in
buildRubyGem rec {
  name = "haste-client-${version}";
  inherit version;
  gemName = "haste";

  source.sha256 = "0jaq0kvlxwvd0jq9pl707saqnaaal3dis13mqwfjbj121gr4hq4q";

  propagatedBuildInputs = [ deps ];

  meta = with lib; {
    description = "CLI Haste Client";
    homepage    = "https://rubygems.org/gems/haste";
    license     = licenses.mit;
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms   = platforms.unix;
  };
}
