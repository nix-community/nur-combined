{ lib
, rustPlatform
, stdenv
, fetchFromGitHub
# note: to change the node version:
# (nodejs-hide-symlinks.override { nodejs = nodejs_20; })
, nodejs
}:

let

  libnodejs-hide-symlinks = rustPlatform.buildRustPackage rec {
    pname = "libnodejs-hide-symlinks";
    version = "unstable-2021-09-29";

    src = fetchFromGitHub {
      owner = "milahu";
      repo = "nodejs-hide-symlinks";
      rev = "38b0fe4a908bf05d6e422040a5de651cfbcb7d18";
      hash = "sha256-jG0xAb86cJAbjsIOZQtbEAPoDUxX+ZSnBS1SisbQ1Z4=";
    };

    cargoHash = "sha256-80NFS2ZwyvV5kwyRBt9fmvDz3OODaAZ7b6UEbpES64g=";

    # FIXME: signal: 11, SIGSEGV: invalid memory reference
    doCheck = false;

    meta = with lib; {
      description = "Hide symlinks from nodejs, to implement a symlinked machine-level global NPM store";
      homepage = "https://github.com/milahu/nodejs-hide-symlinks";
      license = licenses.cc0;
      maintainers = with maintainers; [ ];
    };
  };

in

stdenv.mkDerivation {
  pname = "nodejs-hide-symlinks";
  inherit (nodejs) version;
  src = nodejs;

  passthru = {
    inherit libnodejs-hide-symlinks;
  };

  buildPhase = ''
    mkdir $out
    ln -s $src/* $out
    rm $out/bin
    mkdir $out/bin
    cd $out/bin

    for name in $(ls $src/bin | grep -v -x node); do
    echo creating wrapper: $out/bin/$name
    cat >$name <<EOF
    #!/bin/sh

    LD_PRELOAD=${libnodejs-hide-symlinks}/lib/libnodejs_hide_symlinks.so \\
    exec ${nodejs}/bin/node ${nodejs}/bin/$name "\$@"
    EOF
    chmod +x $name
    done

    echo creating wrapper: $out/bin/node
    cat >node <<EOF
    #!/bin/sh

    LD_PRELOAD=${libnodejs-hide-symlinks}/lib/libnodejs_hide_symlinks.so \\
    exec ${nodejs}/bin/node "\$@"
    EOF
    chmod +x node
  '';

  meta = nodejs.meta // (with lib; {
    description = (
      nodejs.meta.description +
      " - hiding symlinks to the nix store, to implement a symlinked machine-level global NPM store"
    );
  });
}
