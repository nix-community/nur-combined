final: prev: {
  nixGLWrap = package: with final; runCommandNoCC "${package.name}-nixgl-wrapper"
    { nativeBuildInputs = [ makeWrapper ]; }
    ''
      mkdir $out
      ln -s ${package}/* $out
      rm $out/bin
      mkdir $out/bin
      cd $out/bin
      for prog_path in ${package}/bin/*; do
        local prog="$(basename "$prog_path")"
        makeWrapper \
          "${lib.getExe nixgl.auto.nixGLDefault}" \
          "$prog" \
          --argv0 "$prog" \
          --add-flags "$prog_path"
      done
    '';
}
