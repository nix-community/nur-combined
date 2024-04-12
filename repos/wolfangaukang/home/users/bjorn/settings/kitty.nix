{ font
, theme
}:

{
  inherit theme;
  font = {
    package = font.package;
    name = font.family;
    size = font.size;
  };
  shellIntegrationMode = "no-sudo";
}
