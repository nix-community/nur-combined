{ lib }:

with lib;
rec {
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
}

