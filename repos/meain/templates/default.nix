let
  mkTemplate = path: description: { inherit path; inherit description; };

  templates = {
    generic = mkTemplate ./generic "Generic template";
    go-hello = mkTemplate ./go/hello "A simple go package";
  };

  default = templates.generic;
in
{
  inherit templates;
  inherit default;
}
