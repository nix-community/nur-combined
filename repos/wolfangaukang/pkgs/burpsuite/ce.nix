{ callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // {
    url_key = "community";
    bin = "burpsuite";
    type = "Burp Suite Community Edition";
    hash = "sha256-jLwI9r1l/bf2R7BOImEnbW3iLgsF+/1n0/N55Jx8Lzw=";
  }
)
