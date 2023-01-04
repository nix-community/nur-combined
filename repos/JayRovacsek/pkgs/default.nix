{ pkgs ? import <nixpkgs> { } }: {
  better-english = import ./better-english { inherit pkgs; };
}
