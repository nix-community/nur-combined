{ lib
, stdenvNoCC
, qaac-unwrapped
, bubblewrap
}:

stdenvNoCC.mkDerivation rec {
  pname = "qaac-bwrap";
  #inherit (qaac-unwrapped) version meta;
  inherit (qaac-unwrapped) version;
  meta = qaac-unwrapped.meta // {
    license = lib.licenses.mit;
    description = qaac-unwrapped.meta.description + " [sandboxed with bubblewrap]";
  };

  /*
    # moved to qaac/unwrapped.nix
    --setenv WINEDLLPATH ${wine64}y4jnk7zyx8rx4mb-wine64-9.0/lib/wine/x86_64-unix/

    # TODO? be more restrictive
    --ro-bind /nix/store /nix/store \
  */

  #  for bin in qaac refalac; do # TODO? refalac. probably not better than flac

  buildCommand = ''
    mkdir -p $out/bin
    for bin in qaac; do
    echo "writing $out/bin/$bin"
    {
    # write dynamic dependencies of wrapper script
    cat <<EOF
    #!/usr/bin/env bash
    bin='$bin'
    qaac_unwrapped='${qaac-unwrapped}'
    bubblewrap='${bubblewrap}'
    EOF
    # write fixed body of wrapper script
    cat ${./bwrap-common.sh}
    # argparse.sh based on parse-helptext
    if [ "$bin" = "qaac" ]; then
      cat ${./bwrap-qaac.sh}
    elif [ "$bin" = "refalac" ]; then
      : # not implemented
    fi
    } >$out/bin/$bin
    chmod +x $out/bin/$bin
    done
  '';
}
