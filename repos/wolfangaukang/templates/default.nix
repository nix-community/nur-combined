let
  mkTemplate =
    { path
    , description ? ""
    }:

    { inherit path description; };

in
{
  bash = mkTemplate {
    description = "Template for Bash projects (uses resholve)";
    path = ./bash;
  };
  default = mkTemplate {
    path = ./default;
  };
  go = mkTemplate {
    path = ./go;
  };
  python = mkTemplate {
    description = "Template for Python projects that uses Poetry";
    path = ./python;
  };
  rust = mkTemplate {
    description = "Template for Rust projects (uses devenv)";
    path = ./rust;
  };
}
