let
  mkTemplate =
    {
      path,
      description ? "",
    }:

    {
      inherit path description;
    };

in
{
  default = mkTemplate {
    path = ./default;
  };
  go = mkTemplate {
    path = ./go;
  };
  python = mkTemplate {
    description = "Template for Python projects (uses uv)";
    path = ./python;
  };
  rust = mkTemplate {
    path = ./rust;
  };
}
