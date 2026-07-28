{
  lib,
  python3,
  bash,
}:
lib.pipe python3 [
  (x: x.withPackages (p: [ p.scriptipy ]))
  (
    x:
    x.overrideAttrs (old: {
      postBuild = (old.postBuild or "") + ''
        (
          shopt -s failglob dotglob globasciiranges globskipdots
          cd $out/bin
          for fn in *; do
            if [[ $fn == .* ]]; then
              continue
            fi
            if ! [[ -x $fn ]]; then
              echo "warn: non-executable file $out/bin/$fn" >&2
              continue
            fi
            target="$fn"
            if [[ -L $fn ]]; then
              target="$(readlink -- "$fn")"
            fi
            ln -s "$target" "scriptipy-$fn"
          done
        )
        (
          cd $out/bin
          declare pyth_bin="$(readlink python)"
          ln -s "$pyth_bin" scriptipython
          ln -s "$pyth_bin" scriptipy
          printf '#!${lib.getExe bash}\nexec %s -i -c "from scriptipy import *" "$@"\n' "$(readlink -f python)" > scriptipython-repl
          chmod u+x $out/bin/scriptipython-repl
          ln -s scriptipython-repl scriptipy-repl
        )
      '';

      meta = (old.meta or { }) // {
        mainProgram = "scriptipython";
      };
    })
  )
  lib.meta.lowPrio
]
