{ ldap ? false, varDir ? "/var/lib/diaspora", podmin_email ? null, config_dir ? "/etc/diaspora",
  mylibs, stdenv, bundlerEnv, writeText,
  cacert, defaultGemConfig, perl, ruby_2_4, nodejs, which, git }:
let
  diaspora_src = stdenv.mkDerivation (mylibs.fetchedGithub ./diaspora.json // rec {
    buildPhase = ''
      ${if ldap then "patch -p1 < ${./ldap.patch}" else ""}
      # FIXME: bundlerEnv below doesn't take postgresql group for some
      # reason
      echo 'gem "pg",     "1.1.3"' >> Gemfile
    '';
    installPhase = ''
      cp -a . $out
    '';
  });
  gems = bundlerEnv {
    name = "diaspora-env";
    gemfile = "${diaspora_src}/Gemfile";
    lockfile = "${diaspora_src}/Gemfile.lock";
    gemset = if ldap then ./gemset_ldap.nix else ./gemset.nix;
    groups = [ "postgresql" "default" "production" ];
    gemConfig = defaultGemConfig // {
      kostya-sigar = attrs: {
        buildInputs = [ perl ];
      };
    };
  };
  build_config = writeText "diaspora.yml" ''
    configuration:
      environment:
        certificate_authorities: '${cacert}/etc/ssl/certs/ca-bundle.crt'
    ${if podmin_email != null then ''
    # dummy comment for indentation
      admins:
        podmin_email: '${podmin_email}'
    '' else ""}
    production:
      environment:
    '';
  dummy_token = writeText "secret_token.rb" ''
    Diaspora::Application.config.secret_key_base = 'dummy'
  '';
in
stdenv.mkDerivation {
  name = "diaspora";
  inherit diaspora_src;
  builder = writeText "build_diaspora" ''
    source $stdenv/setup
    cp -a $diaspora_src $out
    cd $out
    chmod -R u+rwX .
    tar -czf public/source.tar.gz ./{app,db,lib,script,Gemfile,Gemfile.lock,Rakefile,config.ru}
    ln -s database.yml.example config/database.yml
    ln -s ${build_config} config/diaspora.yml
    ln -s ${dummy_token} config/initializers/secret_token.rb
    ln -sf ${varDir}/schedule.yml config/schedule.yml
    ln -sf ${varDir}/oidc_key.pem config/oidc_key.pem
    ln -sf ${varDir}/uploads public/uploads
    RAILS_ENV=production ${gems}/bin/rake assets:precompile
    ln -sf ${config_dir}/database.yml config/database.yml
    ln -sf ${config_dir}/diaspora.yml config/diaspora.yml
    ln -sf ${config_dir}/secret_token.rb config/initializers/secret_token.rb
    rm -rf tmp log
    ln -sf ${varDir}/tmp tmp
    ln -sf ${varDir}/log log
    '';
  propagatedBuildInputs = [ gems nodejs which git ];
  passthru = { inherit gems varDir; };
}
