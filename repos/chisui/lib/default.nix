args:
let
  java = import ./java args;
in {
  inherit java;
} // java