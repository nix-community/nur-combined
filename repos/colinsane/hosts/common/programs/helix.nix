# Helix text editor
# debug log: `~/.cache/helix/helix.log`
# binary name is `hx`
{ ... }:
{
  sane.programs.helix = {
    persist.plaintext = [ ".config/helix/runtime/grammars" ];
  };
}
