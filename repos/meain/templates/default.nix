let
  mkTemplate = path: description: { path = path; description = description; };

  templates = {
    generic = mkTemplate ./generic "Generic template";
    go-hello = mkTemplate ./go/hello "A simple go package";
  };

  default = templates.generic;
in
{
  templates = templates;
  default = default;
}
