_final: prev:
let
  src = prev.fetchFromGitHub {
    owner = "go-musicfox";
    repo = "go-musicfox";
    rev = "v5.1.0";
    hash = "sha256-gM3gnUbevPSa2gmiC0DGYPrVRtwHF2TQB0Hu99ISVU8=";
  };
in
{
  go-musicfox = prev.go-musicfox.overrideAttrs (_old: {
    version = "5.1.0";
    inherit src;
    vendorHash = "sha256-+lmsd7fqdlKxxXGh6Zwl9xtNXPZrR3xqgROzI9L4xls=";
  });
}
