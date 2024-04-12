{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  url_key = "pro";
  bin = "burpsuite-pro";
  type = "Burp Suite Professional Edition";
  hash = "sha256-xyEQVrfI9CS6div7vZuluKkIm36B9XqKZ9rH+1DjeD4=";
})
