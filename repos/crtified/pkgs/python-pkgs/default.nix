{ callPackage }: rec {
  parsedmarc = callPackage ./parsedmarc { };

  aioairctrl = callPackage ./aioairctrl { };
}
