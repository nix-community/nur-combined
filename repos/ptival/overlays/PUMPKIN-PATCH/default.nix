self: super:
{

  coq = super.coq_8_8;

  coqPackages = super.coqPackages_8_8 // rec {

    coq-extensible-records = self.callPackage ./coq-extensible-records {};

    coq-plugin-lib = self.callPackage ./coq-plugin-lib {};

    fix-to-elim = self.callPackage ./fix-to-elim {
      inherit coq-plugin-lib;
    };

    ornamental-search = self.callPackage ./ornamental-search {
      inherit fix-to-elim;
    };

    PUMPKIN-PATCH = self.callPackage ./PUMPKIN-PATCH {
      inherit coq-plugin-lib;
      inherit fix-to-elim;
      inherit ornamental-search;
    };

  };

}
