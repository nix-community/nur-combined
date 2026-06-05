import ../pkgs/overlay.nix

# or, inlined sane *and* as a scope:
# final: prev: import ../pkgs/overlay.nix final prev // {
#   sane = import ../pkgs/packages.nix final;
# }
#
# or, sane as *only* a scope:
# final: prev: {
#   sane = import ../pkgs/packages.nix final;
# }
