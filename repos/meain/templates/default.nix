let
  mkTemplate = path: description: { inherit path; inherit description; };

  templates = {
    simple = mkTemplate ./simple "A simple template with devShell";
    generic = mkTemplate ./generic "Generic template";
    go = mkTemplate ./go/basic "A basic go package";
  };

  default = templates.simple;
in
{
  inherit templates;
  inherit default;
}
