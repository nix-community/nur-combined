# Originally from https://github.com/Mic92/nix-build-uncached/blob/8cc18174e8d351954d6fe1a2115988f7c1acd10c/scripts/force_cached.nix
#
# Copyright 2020 Jörg Thalheim
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
{
  lib,
  coreutils,
}: let
  # Return true if `nix-build` would traverse that attribute set to look for
  # more derivations to build.
  hasRecurseIntoAttrs = x: builtins.isAttrs x && (x.recurseForDerivations or false);

  # Wrap a single derivation that disallows substitutes so that it can be
  # cached.
  toCachedDrv = drv:
    if !(drv.allowSubstitutes or true)
    then
      derivation {
        name = "${drv.name}-to-cached";
        system = drv.system;
        builder = "/bin/sh";
        args = ["-c" "${coreutils}/bin/ln -s ${drv} $out; exit 0"];
      }
    else drv;

  # Traverses a tree of derivation and wrap all of those that disallow
  # substitutes.
  forceCached = val:
    if lib.isDerivation val
    then toCachedDrv val
    else if hasRecurseIntoAttrs val
    then lib.mapAttrs (_: forceCached) val
    else val;
in
  forceCached
