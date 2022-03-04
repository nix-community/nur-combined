let
  mkTemplate = path: description: { path = path; description = description; };

  templates = {
    generic = mkTemplate ./generic "Generic template";
    rust = mkTemplate ./rust "Template for Rust projects";
    zig = mkTemplate ./zig "Templates for Zig projects";
  };

  default = templates.generic;
in
{
  templates = templates;
  default = default;
}
