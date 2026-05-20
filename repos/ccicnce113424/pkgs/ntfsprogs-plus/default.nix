{
  sources,
  callPackage,
}:
let
  ntfsprogs-plus = callPackage ./package.nix { };
in
ntfsprogs-plus.overrideAttrs (prev: {
  inherit (sources) pname src;
  version = "${prev.version}-unstable-${sources.date}";
})
