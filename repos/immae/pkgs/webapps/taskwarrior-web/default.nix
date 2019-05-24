{ ruby_2_6, bundlerEnv, mylibs, stdenv }:
let
  gems = bundlerEnv {
    name = "taskwarrior-web-env";
    ruby = ruby_2_6;
    pname = "taskwarrior-web";
    gemset = ./gemset.nix;
    gemdir = package.out;
    groups = [ "default" "local" "development" ];
  };
  package = stdenv.mkDerivation (mylibs.fetchedGithub ./taskwarrior-web.json // rec {
    phases = [ "unpackPhase" "patchPhase" "installPhase" ];
    patches = [ ./fixes.patch ./thin.patch ];
    installPhase = ''
      cp -a . $out
      cp ${./Gemfile.lock} $out/Gemfile.lock
      '';
    passthru = {
      inherit gems;
    };
  });
in package
