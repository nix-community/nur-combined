{ base16-shell-preview, base16-templates, writeShellScriptBin }: writeShellScriptBin "base16-shell-preview" ''
  export BASE16_SHELL=${base16-templates.shell}
  exec ${base16-shell-preview}/bin/base16-shell-preview "$@"
''
