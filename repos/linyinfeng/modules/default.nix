{ thisNur }:
{
  vlmcsd = import ./services/vlmcsd.nix { inherit thisNur; };
  trojan = import ./services/trojan.nix { inherit thisNur; };
}
