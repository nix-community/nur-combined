{ stdenv }:
pkg: # pkg must contain $out/bin with executables within.
wrapper: # wrapper must contain @EXECUTABLE@ as a placeholder for the binary to run.
stdenv.mkDerivation {
  name = "${pkg.name}-wrapped";
  version = "1.1.0";
  src = pkg;
  dontUnpack = true;
  meta = pkg.meta;

  installPhase = ''
    for f in $(find -L $src/bin)
    do 
      if [[ ! "$(basename $f)" =~ ^\. ]] && [[ ! -d "$f" ]] && [[ -x "$f" ]]
      then 
        local executable=$out/bin/$(basename "$f")
        install -D ${wrapper} "$executable"
        substituteInPlace "$executable" --subst-var-by EXECUTABLE "$f"
      fi
    done

    if [[ ! -d $out ]]
    then
      echo "ERROR: No executables to wrap were found at $src/bin" 1>&2 
      exit 1
    fi

    # Symlink the share directory so that .desktop files and such continue to work.
    if [[ -h $src/share ]]
    then
      ln -s $(readlink $src/share) $out/share
    elif [[ -d $src/share ]]
    then
      ln -s $src/share $out/share
    fi
  '';
}
