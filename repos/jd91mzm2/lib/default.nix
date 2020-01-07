{ pkgs }:

with pkgs.lib; rec {
  # A variation of sourceByRegex that excludes files based on regex rather than includes them.
  sourceByNotRegex = src: excludes: (
    let
      shouldKeep = path: all (regex: builtins.match regex path == null) excludes;
    in cleanSource (
      cleanSourceWith {
        filter = path: _type: shouldKeep path;
        inherit src;
      }
    )
  );

  # Clean rust sources: Remove `target/` as well as any sqlite databases.
  cleanSourceRust = src: sourceByNotRegex src [
    ''^(.*/)?target(/.*)?$''
    ''^.*\.sqlite$''
  ];
}

