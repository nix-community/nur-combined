{ callPackage, ... } @ args:

callPackage ./generic-v3.nix ({
  version = "3.19.1";
  sha256 = "sha256-IQAlnpsO3AYfzXVnIHxLOKo1XzdWDmwwv+W/OanAl+s=";
} // args)
