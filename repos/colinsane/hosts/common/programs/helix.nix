# Helix text editor
# debug log: `~/.cache/helix/helix.log`
# binary name is `hx`
{ ... }:
{
  sane.programs.helix = {
    # grammars need to be persisted when developing them
    # - `hx --grammar fetch` and `hx --grammar build`
    # but otherwise, they ship as part of HELIX_RUNTIME, in the nix store
    # persist.plaintext = [ ".config/helix/runtime/grammars" ];
  };
}
