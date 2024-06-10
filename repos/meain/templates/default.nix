let
  mkTemplate = path: description: { inherit path; inherit description; };

  templates = {
    generic = mkTemplate ./generic "Generic template";
    go = mkTemplate ./go/basic "A basic go package";
  };

  default = templates.generic;
in
{
  inherit templates;
  inherit default;
}
