self: super:

let
  callPackage = self.callPackage;

in {
  pyscf = callPackage ./pyscf { };
  pyquante = callPackage ./pyquante { };
  pychemps2 = callPackage ./chemps2/PyChemMPS2.nix { };
}
