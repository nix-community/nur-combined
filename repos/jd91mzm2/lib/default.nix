{ lib }:

with lib;

let
  self = rec {
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

    # A simpler version of builtins.split, that disregards the matched splits and
    # just returns a list of regions.
    #
    # "Hello world, how are you?", split on "[[:space:]]", would be ["Hello"
    # "world," "how" "are" "you?"]. As you can see, it doesn't contain the
    # non-string stuff that builtins.split contains.
    simpleSplit = regexp: text: let
      parts = builtins.split regexp text;
      valid = filter builtins.isString parts;
    in valid;

    # Removes all matching parts of a string.
    #
    # stringFilter "[^a-zA-Z0-9]" "Hello, world! The sun's beautiful today, 'innit?" == "HelloworldThesunsbeautifultodayinnit"
    stringFilter = regexp: text: concatStringsSep "" (simpleSplit regexp text);

    # Transforms a string to camel case.
    #
    # toCamelCase "Hello, World!" becomes "helloWorld" using magic.
    toCamelCase = text: let
      # Find alphanumeric words
      alphanumeric = stringFilter "[^a-z0-9[:space:]]" (toLower text);
      words = simpleSplit "[[:space:]]+" alphanumeric;

      # Separate first word
      firstWord = builtins.head words;
      rest = builtins.tail words;

      # Capitilize each word except for the first
      casedRest = builtins.map (s: let
        # First char
        firstChar = builtins.substring 0 1 s;
        # Rest of string
        rest = builtins.substring 1 (builtins.stringLength s - 1) s;
      in (lib.toUpper firstChar) + (lib.toLower rest)) rest;

      # Join all together
      casedAll = [firstWord] ++ casedRest;
    in concatStringsSep "" casedAll;
  };
in

# simple tests can go here
assert self.stringFilter "[^a-zA-Z0-9]" "Hello, world! The sun's beautiful today, 'innit?" == "HelloworldThesunsbeautifultodayinnit";
assert self.toCamelCase "Hello, world!" == "helloWorld";

self
