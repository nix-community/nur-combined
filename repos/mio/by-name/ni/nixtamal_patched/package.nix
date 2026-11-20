{ pkgs }:

# nixtamal from nixpkgs fails to build here: its `matrix` dependency's PTY
# tests read a stopped process's state and CPU time with ps(1) when there is
# no /proc. In the build sandbox macOS refuses the `time` field ("ps: time:
# requires entitlement"), so "SIGTSTP stops the job" and "continued in the
# background, it stops again" fail; console depends on matrix and nixtamal on
# console, so the whole chain fails. Skip that one dependency's checks on
# Darwin, as this repository's OCaml scope already does for saturn; other
# platforms keep them. Nothing about nixtamal itself changes.
#
# The base and its OCaml set both come from pkgs, not from this repository's
# scope: the scope pins OCaml 5.4 for other packages, while nixpkgs' nixtamal
# is built against pkgs.ocamlPackages.
let
  ocamlPackages = pkgs.ocamlPackages.overrideScope (
    _final: prev: {
      matrix = prev.matrix.overrideAttrs (_: {
        doCheck = !pkgs.stdenv.hostPlatform.isDarwin;
      });
    }
  );
in
pkgs.nixtamal.override { inherit ocamlPackages; }
