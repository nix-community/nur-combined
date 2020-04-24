{ varDir ? "/var/lib/mastodon", mylibs,
  stdenv, writeText, runCommand,
  ruby_2_6, bundlerEnv, defaultGemConfig,
  jq, protobuf, protobufc, pkgconfig, libidn, pam, nodejs, yarn, yarn2nix-moretea }:
let
  info = mylibs.fetchedGithub ./mastodon.json // {
    src = runCommand "mastodon-patched" {
      source = (mylibs.fetchedGithub ./mastodon.json).src;
    } ''
    cp -a $source $out
    chmod -R u+w $out
    sed -i -e "/fuubar/s/2.4.0/2.4.1/" $out/Gemfile.lock
    sed -i -e "s/ff00dc470b5b2d9f145a6d6e977a54de5df2b4c9/ff00dc470b5b2d9f145a6d6e977a54de5df2b4c9#4255dc41fa7df9c3a02c1595f058e248bc37b784/" $out/yarn.lock
    '';
  };
  gems = bundlerEnv {
    name = "mastodon-env";
    ruby = ruby_2_6;
    gemset = ./gemset.nix;
    gemdir = info.src;
    groups = [ "default" "production" "test" "development" ];
    gemConfig = defaultGemConfig // {
      redis-rack = attrs: {
        preBuild = ''
          sed -i 's!s\.files.*!!' redis-rack.gemspec
          '';
      };
      tzinfo = attrs: {
        preBuild = ''
          sed -i 's!s\.files.*!!' tzinfo.gemspec
          '';
      };
      cld3 = attrs: {
        buildInputs = [ protobuf protobufc pkgconfig ];
      };
      idn-ruby = attrs: {
        buildInputs = [ libidn ];
      };
      rpam2 = attrs: {
        buildInputs = [ pam ];
      };
    };
  };
  yarnModules = let
    packagejson = runCommand "package.json" { buildInputs = [ jq ]; } ''
      cat ${info.src}/package.json | jq -r '.version = "${info.version}"' > $out
      '';
  in
    yarn2nix-moretea.mkYarnModules rec {
      name = "mastodon-yarn";
      pname = name;
      version = info.version;
      packageJSON = packagejson;
      yarnLock = "${info.src}/yarn.lock";
      yarnNix = ./yarn-packages.nix;
      pkgConfig = {
        uws = {
          postInstall = ''
            npx node-gyp rebuild > build_log.txt 2>&1 || true
            '';
        };
      };
    };
  mastodon_with_yarn = stdenv.mkDerivation (info // rec {
    installPhase = ''
      cp -a . $out
      cp -a ${yarnModules}/node_modules $out
    '';
    buildInputs = [ yarnModules ];
  });
in
stdenv.mkDerivation {
  name = "mastodon";
  inherit mastodon_with_yarn;
  builder = writeText "build_mastodon" ''
      source $stdenv/setup
      set -a
      SECRET_KEY_BASE=Dummy
      OTP_SECRET=Dummy
      set +a
      cp -a $mastodon_with_yarn $out
      cd $out
      chmod u+rwX . public
      chmod -R u+rwX config/ node_modules/
      sed -i -e 's@^end$@  config.action_mailer.sendmail_settings = { location: ENV.fetch("SENDMAIL_LOCATION", "/usr/sbin/sendmail") }\nend@' config/environments/production.rb
      RAILS_ENV=production ${gems}/bin/rails assets:precompile
      rm -rf tmp/cache
      ln -sf ${varDir}/tmp/cache tmp
  '';
  buildInputs = [ gems gems.ruby nodejs yarn ];
  passthru = { inherit gems varDir; };
}
