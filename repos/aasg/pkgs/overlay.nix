self: super:

{

  dma = super.callPackage ./tools/networking/dma { };

  dyndnsc = super.callPackage ./tools/networking/dyndnsc { };

  guile-commonmark = super.callPackage ./development/guile-modules/guile-commonmark { };

  haunt = super.callPackage ./applications/misc/haunt { };

  linuxPackagesFor = kernel:
    (super.linuxPackagesFor kernel).extend (import ./os-specific/linux/kernel-packages.nix);

  python3 = super.python3.override { packageOverrides = import ./development/python-modules; };

}
