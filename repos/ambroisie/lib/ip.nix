# Taken from [1].
#
# [1]: https://gist.github.com/Infinisil/c68a2f385c6d7c52c324d529b7f1d07c
{ lib, ... }:
let
  inherit (lib)
    bitAnd
    concatMapStringsSep
    concatStringsSep
    elemAt
    foldr
    genList
    id
    mod
    range
    toInt
    warn
    zipListsWith
    ;
in
rec {
  # Translate CIDR mask into list of masks to bitwise-and with parsed IPv4
  # address in order to get base address of the subnet
  cidrToMask4 =
    let
      # Generate a partial mask for an integer from 0 to 7
      part = n:
        if n == 0 then 0
        else part (n - 1) / 2 + 128;
    in
    cidr:
    let
      # How many initial parts of the mask are full (=255)
      fullParts = cidr / 8;
      partGen = i:
        # Fill up initial full parts
        if i < fullParts then 255
        # If we're above the first non-full part, fill with 0
        else if fullParts < i then 0
        # First non-full part generation
        else part (mod cidr 8);
    in
    genList partGen 4;

  # Parse an IPv4 address into a list of 4 integers
  parseIp4 = str:
    map toInt (builtins.match "([0-9]+)\\.([0-9]+)\\.([0-9]+)\\.([0-9]+)" str);

  # Parse a given IPv4 subnet into an attribute set containing:
  # * baseIp: the base IP for this subnet
  # * check: a function to check if a parsed IPv4 address is part of this subnet
  # * cidr: the value of the CIDR subnet
  # * mask: the mask corresponding to the CIDR to bitwise-and with the address
  #   and get the base address
  # * range: an attribute set containing `from` and `to`, the lowest and
  #   highest address in the range, in the form of a parsed IPv4 address.
  parseSubnet4 = str:
    let
      splitParts = builtins.split "/" str;
      givenIp = parseIp4 (elemAt splitParts 0);
      cidr = toInt (elemAt splitParts 2);
      mask = cidrToMask4 cidr;
      baseIp = zipListsWith bitAnd givenIp mask;
      range = {
        from = baseIp;
        to = zipListsWith (b: m: 255 - m + b) baseIp mask;
      };
      check =
        ip: isValidIp4 ip && baseIp == zipListsWith (b: m: bitAnd b m) ip mask;
      try =
        if baseIp == givenIp
        then id
        else
          warn (concatStringsSep " " [
            "subnet ${str} has a too specific base address ${prettyIp4 givenIp},"
            "which will get masked to ${prettyIp4 baseIp},"
            "which should be used instead"
          ]);
      nth = n:
        let
          result = nthInRange4 range n;
          try =
            if check result
            then id
            else
              warn (concatStringsSep " " [
                "nth call with n = ${toString n}"
                "is out of range for subnet ${str}"
              ]);
        in
        try result;
    in
    try {
      inherit baseIp check cidr mask nth range;
    };

  # Pretty print a parsed IPv4 address into a human readable form
  prettyIp4 = concatMapStringsSep "." toString;

  # Pretty print a parsed subnet into a human readable form
  prettySubnet4 = { baseIp, cidr, ... }: "${prettyIp4 baseIp}/${toString cidr}";

  # Get the nth address from an IPv4 range
  nthInRange4 = { from, to }: n:
    let
      carry = lhs: { carry, acc }:
        let
          totVal = lhs + carry;
        in
        {
          carry = totVal / 256;
          acc = [ (mod totVal 256) ] ++ acc;
        };
      carried = foldr carry { carry = n; acc = [ ]; } from;
      checkInRange =
        if (to - from) < n
        then
          warn ''
            nthInRange4: '${n}'-th address outside of range (${prettyIp4 from}, ${prettyIp4 to})
          ''
        else id;
    in
    checkInRange carried.acc;

  # Convert an IPv4 range into a list of all its constituent addresses
  rangeIp4 =
    { from, to } @ arg:
    let
      numAddresses =
        builtins.foldl' (acc: rhs: acc * 256 + rhs)
          0
          (zipListsWith (lhs: rhs: lhs - rhs) to from);
    in
    map (nthInRange4 arg) (range 0 numAddresses);

  isValidIp4 = ip:
    (builtins.all (n: n >= 0 && n < 256) ip) && (builtins.length ip == 4);
}
