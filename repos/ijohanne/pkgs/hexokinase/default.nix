{ sources, pkgs, buildGoModule, fetchFromGitHub, ... }:
buildGoModule rec {
  pname = "hexokinase";
  version = "master";
  src = fetchFromGitHub {
    inherit (sources.hexokinase) owner repo rev sha256;
  };
  vendorSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";
  subPackages = [ "." ];
  runVend = false;

  nativeBuildInputs = with pkgs; [ pkg-config ];
  buildInputs = with pkgs; [ ];

  meta = with pkgs.lib; {
    description = "Fast text parser to scrape and convert colours in the form of rgb, rgb, hsl, hsla functions, three and six digit hex values, web colours names, and custom patterns into hex values.";
    license = licenses.mit;
    homepage = "https://github.com/RRethy/hexokinase";
  };
}
