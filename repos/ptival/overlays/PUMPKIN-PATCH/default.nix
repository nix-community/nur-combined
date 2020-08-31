self: super:
{

  coq = super.coq_8_8;

  coqPackages = super.coqPackages_8_8 // rec {

    coq-extensible-records = self.callPackage ../../pkgs/coqPackages/coq-extensible-records {};

    coq-plugin-lib = self.callPackage ../../pkgs/coqPackages/coq-plugin-lib {};

    fix-to-elim = self.callPackage ../../pkgs/coqPackages/fix-to-elim {
      inherit coq-plugin-lib;
    };

    ornamental-search = self.callPackage ../../pkgs/coqPackages/ornamental-search {
      inherit fix-to-elim;
    };

    PUMPKIN-PATCH = self.callPackage ../../pkgs/coqPackages/PUMPKIN-PATCH {
      inherit coq-plugin-lib;
      inherit fix-to-elim;
      inherit ornamental-search;
    };

  };

}
