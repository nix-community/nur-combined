{
  programs.nushell.extraConfig = ''
    $env.config = ($env.config? | default {} | merge {
      table: {
        mode: light
        # header_on_separator: true
      }
    });
  '';
}
