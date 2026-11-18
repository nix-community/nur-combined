# the libs are available to check files
{ callChecks }:
{
  args = callChecks ../group-args.nix { message = "hello"; };
}
