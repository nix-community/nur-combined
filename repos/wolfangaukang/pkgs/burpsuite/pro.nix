{ callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // {
    url_key = "pro";
    bin = "burpsuite-pro";
    type = "Burp Suite Professional Edition";
    hash = "sha256-NpWqrdUaxPvU4O2MplLTRfnqOB2yC/zQJx7o9stjKCU=";
  }
)
