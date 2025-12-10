{ vaculib, ... }:
{
  imports = builtins.attrValues (vaculib.directoryGrabber { path = ./.; });
}
