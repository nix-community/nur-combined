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
    len = toInt (builtins.elemAt split 1);
  in {
    inherit addr len;
  };

  # Convert ipv4 addr/len to prefix like 10.0.0. (len should be a multiple of 8)
  ipv4Prefix = subnet: let
    ip = parseIp subnet;
    parts = splitString "." ip.addr;
    num = ip.len / 8;
  in concatMapStrings (p: p + ".") (sublist 0 num parts);

  # Remove len part of ipv6 subnet/len like fdxx:: (must end with ::)
  ipv6Prefix = subnet: builtins.elemAt (splitString "/" subnet) 0;

  # Append a suffix to ipv4 subnet that ends with x.x.x.0/xx (len is kept)
  ipv4Append = subset: suffix: let
    ip = parseIp subset;
  in "${ipv4Prefix ip.addr}${suffix}/${toString ip.len}";

  # Append a suffix to ipv6 subnet that ends with ::/xx (len is kept)
  ipv6Append = subset: suffix: let
    ip = parseIp subset;
  in "${ip.addr}${suffix}/${toString ip.len}";

  # Check if it is ipv4 with optional len or optional port
  isIpv4 = addr: (builtins.match ''[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+((/[0-9]+)|(:[0-9]+))?'' addr) != null;

  # Convert ipv4 addr to reverse DNS zone domain based on len
  ipv4RdnsZone = addr: len: let
    n = len / 8;
    p = reverseList (sublist 0 n (splitString "." addr));
  in concatStringsSep "." p;

  # Convert ipv4 addr to reverse DNS record name based on len
  ipv4RdnsName = addr: len: let
    n = 4 - len / 8;
    p = sublist 0 n (reverseList (splitString "." addr));
  in concatStringsSep "." p;

  # Epxand all zeros in ipv6 addr
  ipv6Expand = addr: let
    # remove consecutive empty parts (e.g. ::, ::1)
    origParts = splitString ":" addr;
    parts = ifilter0 (i: v: !(v == "" && i > 0 && builtins.elemAt origParts (i - 1) == "")) origParts;
    zeroLen = 8 - builtins.length parts + 1;
  in concatStringsSep ":" (
    flatten (map (p: if p == "" then lists.replicate zeroLen "0000" else padStrLeft "0" 4 p) parts)
  );

  # Convert ipv6 addr to reverse DNS zone domain based on len
  ipv6RdnsZone = addr: len: let
    n = len / 4;
    p = reverseList (sublist 0 n (builtins.filter (v: v != ":") (stringToCharacters (ipv6Expand addr))));
  in concatStringsSep "." p;

  # Convert ipv6 addr to reverse DNS record name based on len
  ipv6RdnsName = addr: len: let
    n = 32 - len / 4;
    p = sublist 0 n (reverseList (builtins.filter (v: v != ":") (stringToCharacters (ipv6Expand addr))));
  in concatStringsSep "." p;
}
