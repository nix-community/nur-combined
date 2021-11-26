{ pkgs }:

with pkgs;

{
  sddm = recurseIntoAttrs {
    clairvoyance = callPackage ./sddm/clairvoyance { };
  };

  lightdm-webkit2-greeter = recurseIntoAttrs {
    litarvan = callPackage ./lightdm-webkit2-greeter/litarvan { };
  };
}
