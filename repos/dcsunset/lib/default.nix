{ lib }:

with lib;
rec {
  # fitler file names with predicate in dir
  filterDir = pred: dir:
    builtins.attrNames (
      filterAttrs
        pred
        (builtins.readDir dir)
    );

  # read all modules in a directory as a list
  # dir should be a path
  readModules = dir: map
    (m: dir + "/${m}")
    (filterDir
      # if it's a directory, it should contain default.nix
      (n: v: v == "directory" || strings.hasSuffix ".nix" n)
      dir);

  # list names of all subdirectories in a dir
  listSubdirNames = filterDir (n: v: v == "directory");

  # list paths of all subdirectories in a dir
  listSubdirPaths = dir: map (x: dir + "/${x}") (listSubdirNames dir);

  # import all modules in subdirs
  importSubdirs = dir: map import (listSubdirPaths dir);

  # read multiple files and concat them into one string by newlines
  readFiles = files: concatStringsSep "\n" (
    map builtins.readFile files
  );

  recursiveMergeAttrs = attrs: foldl' (acc: attr: recursiveUpdate acc attr) {} attrs;


  ### Strings

  # Remove multiple possible suffixes
  removeSuffixes = suffixes: str:
    foldl'
      (acc: suffix: removeSuffix suffix acc)
      str
      suffixes;

  # Pad string to length from left
  padStrLeft = char: len: str: let
    padLen = len - builtins.stringLength str;
    padding = if padLen > 0 then strings.replicate padLen char else "";
  in padding + str;


  ### Network

  # Parse ip and len from format addr/len
  parseIp = subnet: let
    split = splitString "/" subnet;
    addr = builtins.elemAt split 0;
    len = builtins.elemAt split 1;
  in {
    inherit addr len;
  };

  # Convert ipv4 subnet/len or subnet to prefix like 10.0.0. (must end with .0)
  ipv4Prefix = subnet: removeSuffix "0" (builtins.elemAt (splitString "/" subnet) 0);

  # Use the prefix as gateway (without len) as it's not a special addr in IPv6
  # Convert ipv6 subnet/len to prefix like fdxx:: (must end with ::)
  ipv6Prefix = subnet: builtins.elemAt (splitString "/" subnet) 0;

  # Append a suffix to ipv4 subnet that ends with x.x.x.0/xx (len is kept)
  ipv4Append = subset: suffix: let
    ip = parseIp subset;
  in "${ipv4Prefix ip.addr}${suffix}/${ip.len}";

  # Append a suffix to ipv6 subnet that ends with ::/xx (len is kept)
  ipv6Append = subset: suffix: let
    ip = parseIp subset;
  in "${ip.addr}${suffix}/${ip.len}";

  # Check if it is ipv4 with optional len or optional port
  isIpv4 = addr: (builtins.match ''[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+((/[0-9]+)|(:[0-9]+))?'' addr) != null;

  # Convert ipv4 subnet/len to reverse DNS domain based on len
  ipv4RdnsDomain = subnet: let
    ip = parseIp subnet;
    n = (toInt ip.len) / 8;
    p = sublist 0 n (splitString "." ip.addr);
  in concatStringsSep "." (reverseList p);

  # Epxand all zeros in ipv6 addr
  ipv6Expand = addr: let
    # remove consecutive empty parts (e.g. ::, ::1)
    origParts = splitString ":" addr;
    parts = ifilter0 (i: v: !(v == "" && i > 0 && builtins.elemAt origParts (i - 1) == "")) origParts;
    zeroLen = 8 - builtins.length parts + 1;
  in concatStringsSep ":" (
    flatten (map (p: if p == "" then lists.replicate zeroLen "0000" else padStrLeft "0" 4 p) parts)
  );

  # Convert ipv6 subnet/len to reverse DNS domain based on len
  ipv6RdnsDomain = subnet: let
    ip = parseIp subnet;
    n = toInt ip.len / 4;
    p = sublist 0 n (builtins.filter (v: v != ":") (stringToCharacters (ipv6Expand ip.addr)));
  in concatStringsSep "." (reverseList p);
}
