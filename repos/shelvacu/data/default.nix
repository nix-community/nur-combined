{ vaculib, ... }:
{
  _class = "vacuData";
  
  imports = vaculib.directoryGrabberList ./.;

  options.data = { };
}
