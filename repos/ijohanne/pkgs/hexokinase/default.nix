{ sources, pkgs, buildGoModule, ... }:
buildGoModule rec {
  pname = "hexokinase";
  version = "master";
  src = sources.hexokinase;
  vendorHash = null;
  subPackages = [ "." ];
  proxyVendor = false;

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ ];

  meta = with pkgs.lib; {
    description = "Fast text parser to scrape and convert colours in the form of rgb, rgb, hsl, hsla functions, three and six digit hex values, web colours names, and custom patterns into hex values.";
    license = licenses.mit;
    homepage = "https://github.com/RRethy/hexokinase";
  };
}
