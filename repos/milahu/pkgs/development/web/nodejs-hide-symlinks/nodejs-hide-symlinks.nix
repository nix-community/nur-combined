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
    version = "unstable-2023-09-07";

    src = fetchFromGitHub {
      owner = "milahu";
      repo = "nodejs-hide-symlinks";
      rev = "ad088b00b0bcfb6c6f8444f257b14e7f8551313b";
      hash = "sha256-y6F2ZrbmFFK06tLPjMmDWUIa6JAAzexV1u8K5B1wUVo=";
    };

    cargoHash = "sha256-6kqOXgFI0Y++PEnGM8jrQzQA5k9PAgV1ORCCH4lLiNw=";

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
