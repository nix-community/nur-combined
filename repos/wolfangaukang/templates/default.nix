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
  cloudformation = mkTemplate {
    path = ./cloudformation;
  };
  go = mkTemplate {
    path = ./go;
  };
  hcl2 = mkTemplate {
    path = ./hcl2;
  };
  markdown = mkTemplate {
    description = "Sets a Markdown environment with dprint";
    path = ./markdown;
  };
  perl = mkTemplate {
    path = ./perl;
  };
  python = mkTemplate {
    description = "Template for Python projects that uses Poetry";
    path = ./python;
  };
  rust = mkTemplate {
    path = ./rust;
  };
}
