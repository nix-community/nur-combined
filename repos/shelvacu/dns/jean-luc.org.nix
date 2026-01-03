{ dnsData, ... }:
let
  s = x: [ x ];
  inherit (dnsData) propA;
in
{
  vacu.liamMail = true;
  A = propA;
  NS = [
    {
      nsdname = "ns2.afraid.org.";
      ttl = 60 * 60;
    }
  ];
  subdomains = {
    # keep-sorted start block=yes
    "_a908498ee692a9729bf12e161ae1887d.tdi-readings".CNAME =
      s "_1f055e4fc0f439e67304a33945d09002.hkvuiqjoua.acm-validations.aws.";
    "_acme-challenge".CNAME = s "8cc7a174-c4a6-40f5-9fff-dfb271c5ce0b.auwwth.dis8.net.";
    "in".vacu.liamMail = true;
    "stats".A = propA;
    "tdi-readings".CNAME = s "d20l6bh1gp7s8.cloudfront.net.";
    "www".A = propA;
    # keep-sorted end
  };
}
