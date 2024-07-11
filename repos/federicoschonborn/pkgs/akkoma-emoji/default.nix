{ self, lib }:

{
  av70 = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage;
      directory = ./av70;
    }
  );

  eevee = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage;
      directory = ./eevee;
    }
  );

  eppa = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage;
      directory = ./eppa;
    }
  );

  fotoente = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage;
      directory = ./fotoente;
    }
  );

  mahiwa = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage;
      directory = ./mahiwa;
    }
  );

  moonrabbits = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage;
      directory = ./moonrabbits;
    }
  );

  olivvybee = lib.recurseIntoAttrs (
    let
      mkEmojiPack = self.callPackage ./olivvybee/mkEmojiPack.nix { };
    in
    {
      inherit mkEmojiPack;
    }
    // builtins.mapAttrs (name: hash: mkEmojiPack { inherit name hash; }) {
      blobbee = "sha256-NnamiabNStT1grH2yxczFDUlVut0CQMBbGX3uIWTbwo=";
      fox = "sha256-EbEfbffz+MdVF33x7nP59je20xsq1+pkGeyTJVtKDTA=";
      neobread = "sha256-ou9GCDoTTpvgqp35D1bFj7y0JybO4UDEofu03avhhaw=";
      neodlr = "sha256-Cx/eJnX1LTKYsb43OiefRApK8MtuIj+w6KI9tEQ99Xs=";
      neofriends = "sha256-4IQNQ+idJeqO09GK0lLuFnXXyNggGGHpG+J3qTRW49Y=";
      neossb = "sha256-+4pHxLriFcB8Ryq44nim4sn4E7ENVaMEftsda67Vt7c=";
    }
  );

  renere = lib.recurseIntoAttrs (
    lib.packagesFromDirectoryRecursive {
      inherit (self) callPackage;
      directory = ./renere;
    }
  );

  volpeon = lib.recurseIntoAttrs (
    let
      mkEmojiPack = self.callPackage ./volpeon/mkEmojiPack.nix { };
    in
    {
      inherit mkEmojiPack;
    }
    // builtins.mapAttrs (name: { version, hash }: mkEmojiPack { inherit name version hash; }) {
      drgn = {
        version = "3.1";
        hash = "sha256-9SdjY51jeAIKz+CP2I1IL9d2EwN+NWAfuM+3FAMi4Oo=";
      };
      floof = {
        version = "1.0";
        hash = "sha256-N8A5YqpJK2vz+aGRQ40l+V39w6SNE3JLNyVxZxNkVIo=";
      };
      gphn = {
        version = "1.2";
        hash = "sha256-p1MT/u7pzx2UBLQuVD0dMmZ/uacVN6fTOrTzqLZNkts=";
      };
      neocat = {
        version = "1.1";
        hash = "sha256-FLtaIqBZqZGC51NX6HiwEzWBlx1GpstZcgpnMDFTuQk=";
      };
      neofox = {
        version = "1.3";
        hash = "sha256-zHbiRiEOwGlmm9TRvL25ngCK04rJHzYsLxz2PUjf3GA=";
      };
      vlpn = {
        version = "1.1";
        hash = "sha256-NNBNGS9S2iZCj76xJ6PJdxyHCfpP+yoYVuX8ORzpYrs=";
      };
    }
  );
}
