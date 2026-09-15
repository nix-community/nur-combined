{ lib }:
{
  hash,
  rev,
  url,
}:
builtins.getFlake "${url}/archive/${rev}.tar.gz?narHash=${lib.escapeURL hash}"
