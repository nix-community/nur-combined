{ ... }:
let
  s = x: [ x ];
in
{
  vacu.ns.vanity = 6;
  A = s "52.10.104.133";
  AAAA = s "2600:1f13:d05:c300:406f:87c:2e7e:a372";
  subdomains = {
    admin.CNAME = s "consortium.chat.";
    matrix.CNAME = s "consortium.chat.";
  };
}
