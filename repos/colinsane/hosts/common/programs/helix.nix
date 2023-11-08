# Helix text editor
# debug log: `~/.cache/helix/helix.log`
# binary name is `hx`
{ ... }:
{
  sane.programs.helix = {
    # grammars need to be persisted when developing them
    # - `hx --grammar fetch` and `hx --grammar build`
    # but otherwise, they ship as part of HELIX_RUNTIME, in the nix store
    # persist.byStore.plaintext = [ ".config/helix/runtime/grammars" ];
    fs.".config/helix/config.toml".symlink.text = ''
      # docs: <https://docs.helix-editor.com/configuration.html>
      [editor.soft-wrap]
      enable = true

      [editor.whitespace.render]
      space = "all"
      tab = "all"
      newline = "none"
    '';
  };
}
