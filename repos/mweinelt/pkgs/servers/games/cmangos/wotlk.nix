{ callPackage, ... } @ args:

callPackage ./generic.nix (args // {
  flavor = "wotlk";
  rev = "222570e001d55cdc1ad80d2c8e18e1c876e88f1c";
  hash = "sha256:0qyk3hyw2x7l8xsbk5mfcq6q89f94aady4hpq4rbyy34hn4zbr0f";
})
