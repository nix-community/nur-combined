{ pkgs }:

with pkgs.lib; {
  # Add your library functions here
  #
  # hexint = x: hexvals.${toLower x};
  lists = rec {
    foldmap = seed: acc: func: list:
      let
        acc' = if acc == [] then [seed] else acc;
        x = head list;
        xs = tail list;
      in if list == [] then acc
         else acc ++ (foldmap seed [(func x acc')] func xs);
  };
  # https://github.com/NixOS/nixpkgs/issues/36299
  ip4 = rec {
    pow = n : i :
      if i == 1 then
        n
      else
        if i == 0 then
          1
    else
      n * pow n (i - 1);

    ip = a : b : c : d : prefixLength : {
      inherit a b c d prefixLength;
      address = "${toString a}.${toString b}.${toString c}.${toString d}";
    };

    toCIDR = addr : "${addr.address}/${toString addr.prefixLength}";
    toNetworkAddress = addr : with addr; { inherit address prefixLength; };
    toNumber = addr : with addr; a * 16777216 + b * 65536 + c * 256 + d;
    fromNumber = addr : prefixLength :
      let
        aBlock = a * 16777216;
        bBlock = b * 65536;
        cBlock = c * 256;
        a      =  addr / 16777216;
        b      = (addr - aBlock) / 65536;
        c      = (addr - aBlock - bBlock) / 256;
        d      =  addr - aBlock - bBlock - cBlock;
      in
        ip a b c d prefixLength;

    fromString = str :
      let
        splits1 = splitString "." str;
        splits2 = flatten (map (x: splitString "/" x) splits1);

        e = i : toInt (builtins.elemAt splits2 i);
      in
        ip (e 0) (e 1) (e 2) (e 3) (e 4);

    fromIPString = str : prefixLength :
      fromString "${str}/${toString prefixLength}";

    network' = x: (network x).address;
    networkCIDR = x: toCIDR (network x);
    netmask' = x: (netmask x).address;
    wildcard' = x: (wildcard x).address;
    broadcast' = x: (broadcast x).address;
    first' = x: (first x).address;
    next' = x: (next x).address;
    prev' = x: (prev x).address;
    last' = x: (last x).address;

    network = addr :
      let
        pfl = addr.prefixLength;
        shiftAmount = pow 2 (32 - pfl);
      in
        fromNumber ((toNumber addr) / shiftAmount * shiftAmount) pfl;
    netmask = addr :
      let
        pfl = addr.prefixLength;
        shiftAmount = pow 2 (32 - pfl);
      in
        fromNumber (bitAnd (4294967295 * shiftAmount) 4294967295) pfl;
    wildcard = addr :
      let
        pfl = addr.prefixLength;
      in
        fromNumber (bitAnd (bitNot (toNumber (netmask addr))) 4294967295) pfl;
    broadcast = addr :
      let
        pfl = addr.prefixLength;
      in
        fromNumber (bitOr (toNumber addr) (toNumber (wildcard addr))) pfl;

    first = addr :
      let
        number = toNumber (network addr) + 1;
        newaddr = fromNumber number addr.prefixLength;
      in newaddr;
    next = addr :
      let
        number = toNumber addr + 1;
        newaddr = fromNumber number addr.prefixLength;
      in newaddr;
    prev = addr :
      let
        number = toNumber addr - 1;
        newaddr = fromNumber number addr.prefixLength;
      in newaddr;
    last = addr :
      let
        number = toNumber (broadcast addr) - 1;
        newaddr = fromNumber number addr.prefixLength;
      in newaddr;
  };
  systemd = {
    LockPersonality = true;
    PrivateIPC = true;
    PrivateMounts = true;
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    RestrictNamespaces = true;
    RestrictRealtime = true;
    MemoryDenyWriteExecute = true;
    SystemCallArchitectures = "native";
    SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @resources";
  };
}
