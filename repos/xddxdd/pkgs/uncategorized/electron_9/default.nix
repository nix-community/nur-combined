{ callPackage }:

let
  mkElectron = callPackage ../electron_11/generic.nix { };
in
mkElectron "9.4.4" {
  x86_64-linux = "sha256-eB1sqDTUFccQeOHCwZj6upJtb84Z4xRIu/RFCGkTVFA=";
  x86_64-darwin = "sha256-9BwL+HTdu6AMPWmJ0H90FVojbi1aPq89HRnvjT6yJWw=";
  i686-linux = "sha256-QON/j5CKgcn6wQc/4iMJzW3y1o5oX4MnTG0vCVkAQYc=";
  armv7l-linux = "sha256-Lf4+IdMFJmiMw9MhXQbf3cpZeiy2L/DJ0NXzPT5GSjM=";
  aarch64-linux = "sha256-8RRemh/rXylV5fVWWWJCOsPFL/5FzMO5bGykhfo1vyc=";
  headers = "sha256-BSG+MM4d2he7H3OFSXfTaSlXmBbvwA/PSQqWUPOsqHs=";
}
