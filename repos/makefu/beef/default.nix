{ stdenv, bundlerEnv, ruby, fetchFromGitHub, nodejs }:
# nix-shell --command "bundler install && bundix" in the clone, copy gemset.nix, Gemfile and Gemfile.lock
let
  gems = bundlerEnv {
    name = "beef-env";
    inherit ruby;
    gemdir  = ./.;
  };
in stdenv.mkDerivation {
  name = "beef-2018-09-21";
  src = fetchFromGitHub {
    owner = "beefproject";
    repo = "beef";
    rev = "d237c95";
    sha256 = "1mykbjwjcbd2a18wycaf35hi3b9rmvqz1jnk2v55sd4c39f0jpf2";
  };
  prePatch = ''
    ls -alhtr
  '';
  patches = [ ./db-in-homedir.patch ];
  buildInputs = [gems ruby];
  installPhase = ''
    mkdir -p $out/{bin,share/beef}

    cp -r * $out/share/beef
    # set the default db path, unfortunately setting to /tmp does not seem to work
    # sed -i 's#db_file: .*#db_file: "/tmp/beef.db"#' $out/share/beef/config.yaml

    bin=$out/bin/beef
    cat > $bin <<EOF
#!/bin/sh -e
PATH=$PATH:${nodejs}/bin/
exec ${gems}/bin/bundle exec ${ruby}/bin/ruby $out/share/beef/beef "\$@"
EOF
    chmod +x $bin
  '';

  meta = with stdenv.lib; {
    homepage = https://beefproject.com/;
    description = "The Browser Exploitation Framework";
    platforms = platforms.linux;
    maintainers = with maintainers; [ makefu ];
  };

}
