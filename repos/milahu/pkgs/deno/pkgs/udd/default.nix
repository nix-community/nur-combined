/*
nix-build . -A deno.pkgs.udd
*/

{ deno
, stdenv
, fetchFromGitHub
, jq
}:

stdenv.mkDerivation rec {

  pname = "udd";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "hayd";
    repo = "deno-udd";
    rev = version;
    sha256 = "sha256-JVXqZq6Ldt/jBqjTFbobCVMb1XjjnE+AQnBfd13eIMA=";
    #fetchSubmodules = true;
  };

  denoDirHash = "sha256-SZldhIE7+m/EUXmeuL+GIQYUKss1JqOxdvD9sn/ZHXg=";

  meta = {
    description = "Update Deno Dependencies - update dependency urls to their latest published versions";
    homepage = "https://github.com/hayd/deno-udd";
  };

  mainScript = "main.ts";

  buildInputs = [ deno ];

  # TODO? deno cache -> deno vendor
  # TODO upstream this to deno2nix
  denoDir = stdenv.mkDerivation {
    inherit src patches;
    buildInputs = buildInputs ++ [ jq ];
    name = "${pname}-${version}-deno-dir";
    # fixed output drv
    outputHash = denoDirHash;
    outputHashMode = "recursive";
    outputHashAlgo = "sha256";
    buildPhase = ''
      export DENO_DIR=$PWD/../build
      mkdir -p $DENO_DIR

      # debug deno
      export RUST_BACKTRACE=full

      # note: $DENO_DIR/lock.json is a non-standard location
      echo fetching DENO_DIR
      deno cache --lock=$DENO_DIR/lock.json --lock-write ${mainScript}

      echo making deterministic DENO_DIR
      # workaround for
      # deno cache: add option: deterministic
      # https://github.com/denoland/deno/issues/16296
      find $DENO_DIR/deps -name '*.metadata.json' |
      while read j
      do
        # workaround for
        # error: missing field `headers` at line 3 column 1
        #cat $j | jq 'del(.headers) | del(.now)' >$j.new
        # https://github.com/denoland/deno/issues/16295
        cat $j | jq '.headers={} | del(.now)' >$j.new
        mv $j.new $j
      done
      rm $DENO_DIR/dep_analysis_cache_v1

      echo rebuilding DENO_DIR
      deno cache --lock=$DENO_DIR/lock.json ${mainScript}
    '';
    installPhase = ''
      cp -r $DENO_DIR $out
    '';
    /*
      # append whitespace to force rebuild of denoDir
      echo >>$out
    */
  };

  patches = [];

  # not working. "deno task" does not take --lock
  #deno task --lock=${lockfile} build

  # TODO refactor build of $out/bin/udd. makeDenoWrapper? wrapDenoScript?

  # DENO_IMPORT_MAP: override imports
  # https://deno.land/manual@v1.26.1/linking_to_external_code/import_maps
  # https://deno.land/manual@v1.26.1/node/import_maps

  buildPhase = ''
    echo "deno version:"
    deno --version

    export DENO_DIR=$out/share/deno

    mkdir -p $(dirname $DENO_DIR)
    ln -s -v ${denoDir} $DENO_DIR

    mkdir -p $out/bin

    cat >$out/bin/udd <<EOF
    #! /bin/sh

    export DENO_DIR='$DENO_DIR'

    args=()

    if [ -n "\$DENO_IMPORT_MAP" ]
    then
      args+=("--import-map=\$DENO_IMPORT_MAP")
    fi

    exec ${deno}/bin/deno \\
      run \\
      \''${args[@]} \\
      -A --unstable --cached-only \\
      --lock=$DENO_DIR/lock.json \\
      ${src}/${mainScript}
    EOF

    chmod +x $out/bin/udd
  '';

  dontInstall = true;

}
