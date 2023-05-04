# this directory contains data of a factual nature.
# for example, public ssh keys, GPG keys, DNS-type name mappings.
#
# don't put things like fully-specific ~/.config files in here,
# even if they're "relatively unopinionated".

moduleArgs:

{
  feeds = import ./feeds moduleArgs;
  keys = import ./keys.nix;
}
