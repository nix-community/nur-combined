{ lib, callPackage }:

{
  eevee = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./eevee;
    }
  );

  eppa = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./eppa;
    }
  );

  fotoente = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./fotoente;
    }
  );

  mahiwa = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./mahiwa;
    }
  );

  moonrabbits = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./moonrabbits;
    }
  );

  olivvybee = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./olivvybee;
    }
  );

  pleroma = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./pleroma;
    }
  );

  renere = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./renere;
    }
  );

  volpeon = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./volpeon;
    }
  );

  wep = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./wep;
    }
  );
}
