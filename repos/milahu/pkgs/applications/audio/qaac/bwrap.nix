{ lib
, writeShellApplication
, qaac-unwrapped
, bubblewrap
}:

writeShellApplication rec {
  name = qaac-unwrapped.meta.mainProgram;
  runtimeInputs = [
  ];
  # TODO bubblewrap add (ro) input and (rw) output paths to sandbox
  /*
    # moved to qaac/unwrapped.nix
    --setenv WINEDLLPATH ${wine64}y4jnk7zyx8rx4mb-wine64-9.0/lib/wine/x86_64-unix/

    # TODO? be more restrictive
    --ro-bind /nix/store /nix/store \
  */
  text = ''
    exec ${bubblewrap}/bin/bwrap \
    --chdir / \
    --tmpfs /tmp \
    --ro-bind /nix/store /nix/store \
    --setenv WINEPREFIX $HOME/.cache/qaac/wine \
    --bind $HOME/.cache/qaac/wine $HOME/.cache/qaac/wine \
    ${qaac-unwrapped}/bin/qaac \
    "$@"
  '';
  inherit (qaac-unwrapped) meta;
  checkPhase = ":"; # dont shellcheck
}
