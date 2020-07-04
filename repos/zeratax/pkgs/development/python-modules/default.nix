{ callPackage }:

rec {
  html-sanitizer = callPackage ./html-sanitizer { };

  matrix-nio = callPackage ./matrix-nio { };

  pyfastcopy = callPackage ./pyfastcopy { };
}