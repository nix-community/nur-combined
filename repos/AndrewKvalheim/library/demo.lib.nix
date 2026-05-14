{ lib, pkgs }:

let
  inherit (builtins) attrNames groupBy filter head mapAttrs tail;
  inherit (lib) concatLines concatStringsSep filterAttrs mapAttrsToList mapCartesianProduct mutuallyExclusive;
  inherit (import ./identity.lib.nix { inherit lib; }) contactNotice;
  inherit (import ./palette.lib.nix { inherit lib; inherit pkgs; }) colors;
  inherit (import ./utilities.lib.nix { inherit lib; }) bullet columns compose cull indent lookup ne sgr;
in
{
  inherit contactNotice;

  palette = with sgr; concatLines (mapAttrsToList
    (name: { css, hex, sgr, ... }: "${sgr "██ ${name}"} ${brightBlack "${css} ≈ ${hex}"}")
    (filterAttrs (_: a: a ? css) colors)
  );

  sgr =
    let
      archetype = lookup { "22" = "bold"; "23" = "italic"; "24" = "underline"; "27" = "inverse"; "29" = "strike"; "39" = "blue"; };
      groups = mapAttrs (_: map (a: a.n)) (groupBy (a: a.off) (mapAttrsToList (n: f: { inherit n; inherit (f null) off; }) sgr));

      combine = keep: xs: f: filter (v: v != null) (mapCartesianProduct ({ a, b }: if keep a b then f a b else null) { a = xs; b = xs; });
      combineGroups = combine ne (attrNames groups);
      combineGroupss = f: combine mutuallyExclusive (combineGroups f);
      nest = nss:
        let ns = head nss; nss' = tail nss; l = concatStringsSep "-" ns; in
        (compose (map (lookup sgr) ns)) (if nss' == [ ] then l else "${l}${nest nss'}${l}");
    in
    concatStringsSep "\n" (mapAttrsToList (k: v: "${k}:\n\n${indent 2 (columns "  " (map bullet v))}\n") {
      "Attributes" = mapAttrsToList (g: ns: columns " " (map (n: nest [ [ n ] ]) ns)) groups;
      "Composition" = combineGroups (a: b: nest [ [ (archetype a) (archetype b) ] ]);
      "Nesting" = combineGroups (a: b: nest [ [ (archetype a) ] [ (archetype b) ] ]);
      "Nesting of composition" = cull 32 (combineGroupss (a: b: [ (archetype a) (archetype b) ]) (a: b: nest [ a b ]));
    });
}
