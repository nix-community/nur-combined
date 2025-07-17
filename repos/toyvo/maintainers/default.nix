{
  jinja2-cli,
  writeShellScriptBin,
}:
{
  render_templates = writeShellScriptBin "render_templates" ''
    find . -name "*.j2" -print0 | while read -d $'\0' file; do
      ${jinja2-cli}/bin/jinja2 "$file" config.yml --format=yml > "''${file%.j2}"
    done
  '';
}
