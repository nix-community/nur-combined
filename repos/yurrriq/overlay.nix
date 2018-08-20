# You can use this file as a nixpkgs overlay.
# It's useful in the case where you don't want to add the whole NUR namespace
# to your configuration.

self: super: (import ./default.nix { pkgs = super; }).pkgs
