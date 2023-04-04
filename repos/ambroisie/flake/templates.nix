{ self, ... }:
{
  flake.templates = import "${self}/templates";
}
