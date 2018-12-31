self: super:
{
  flangPackages_5 = super.callPackage ./llvm/5 { };
  flangPackages_6 = super.callPackage ./llvm/6 { };
  flangPackages_7 = super.callPackage ./llvm/7 { };
}
