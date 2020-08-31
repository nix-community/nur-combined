let

  haskellOverlay =
    { ghcVersion, makeHaskellPackagesOverlay }:
    self: super:
    let
      haskellPackagesOverlay = makeHaskellPackagesOverlay self super;
      anotherGHC =
          if ghcVersion == "ghc865"
          then "ghc882"
          else if ghcVersion == "ghc882"
          then "ghc865"
          else if ghcVersion == "ghc883"
          then "ghc882"
          else if ghcVersion == "ghc8101"
          then "ghc882"
          else throw ("You need to define what GHC to use to avoid infinite loops with " ++ ghcVersion);
      haskellPackages = super.haskell.packages.${ghcVersion}.extend haskellPackagesOverlay;
    in
      {
        # this prevents infinite recursion when defining other Haskell overlays
        # the GHC version for cabal2nix must be different from the one being extended
        # cf. https://github.com/NixOS/nixpkgs/issues/83098
        cabal2nix-unwrapped = self.haskell.lib.justStaticExecutables (
          self.haskell.lib.generateOptparseApplicativeCompletion
            "cabal2nix"
            super.haskell.packages.${anotherGHC}.cabal2nix
        );
        inherit haskellPackages;
        haskell = super.haskell // { packages = super.haskell.packages // { "${ghcVersion}" = haskellPackages; }; };
      };

in

{

  "ghc865" =
    haskellOverlay {
      ghcVersion = "ghc865";
      makeHaskellPackagesOverlay = self: super: selfH: superH:
        let
          dontCheck = super.haskell.lib.dontCheck;
        in
          {

            # current nixpkgs revision points to 2.4 which is annoying
            Cabal = selfH.callHackage "Cabal" "3.0.0.0" {};

            floskell = dontCheck superH.floskell;

            # ghcide = dontCheck superH.ghcide;

            haskell-language-server = dontCheck
              (selfH.callCabal2nix
                "haskell-language-server"
                (builtins.fetchGit {
                  url = "https://github.com/haskell/haskell-language-server.git";
                  rev = "144457f37f9760fae19fb02e18f0471c0ba2204b";
                })
                {});

            # ghcide-0.1.0 needs 0.19.0, but Hackage has 0.20.0
            haskell-lsp       = selfH.callHackage "haskell-lsp"       "0.19.0.0" {};
            haskell-lsp-types = selfH.callHackage "haskell-lsp-types" "0.19.0.0" {};

            # 1.21.1 as mandated by hlint-2.1.17
            haskell-src-exts = selfH.callHackage "haskell-src-exts" "1.21.1" {};

            haskell-src-meta = dontCheck superH.haskell-src-meta;

            hie-bios = dontCheck superH.hie-bios;

            # 2.1.17 is the last version that will work with GHC 8.6.5
            hlint = selfH.callHackage "hlint" "2.1.17" {};

            # 5.0.17.11 is the last version compatible with haskell-src-exts-1.21.1
            hoogle = selfH.callHackage "hoogle" "5.0.17.11" {};

            # stack = selfH.callHackage "stack" "2.1.3.1" {};

            # pantry = selfH.callHackage "pantry" "0.2.0.0" {};

            # 1.9.3, isn't on Hackage for my nixpkgs revision
            time-compat = dontCheck
              (selfH.callCabal2nix
                "time-compat"
                (builtins.fetchGit {
                  url = "https://github.com/phadej/time-compat.git";
                  rev = "0406505ddde5affb39f72070e18352c766ca4eb8";
                })
                {});

          };
    };

  "ghc882" =
    haskellOverlay {
      ghcVersion = "ghc882";
      makeHaskellPackagesOverlay = self: super: selfH: superH:
        let
          dontCheck = super.haskell.lib.dontCheck;
        in
          {

            # cabal-helper is not yet compatible with 3.2.0.0
            # cabal-install = selfH.callHackage "cabal-install" "3.0.0.0" {};
            # enforce Cabal 3.2.0.0 for hie
            Cabal = selfH.callHackage "Cabal" "3.0.1.0" {};
            # hie seems to care about Cabal being 3.2.0.0
            # cabal-helper = ...;

            # 3.0.2.0 seemingly never existed, this is 3.0.1.0 which never got released
            cabal-install = dontCheck
              (selfH.callCabal2nix
                "cabal-install"
                (self.pkgs.fetchFromGitHub {
                  owner  = "haskell";
                  repo   = "cabal";
                  rev    = "ef1d0c58994feff83cf8ac4d162c92d459541bfa";
                  sha256 = "sha256:183hqzys2bqnvd07wxd5zhdci7qwfxsvkhsxwy7zbnxfdjgfp634";
                } + "/cabal-install")
                {}
              );

            floskell = dontCheck superH.floskell;

            # current Hackage has old bound for haskell-lsp
            ghcide = dontCheck
              (selfH.callCabal2nix
                "ghcide"
                (self.pkgs.fetchFromGitHub {
                  owner  = "alanz";
                  repo   = "ghcide";
                  rev = "0db329a62375f086725571aa14e52f7b9f85ac3b";
                  sha256 = "sha256:02249zask2c2rr2npw7aj0ihmwj9a7kxzg38ibrb9r06wq93lrj7";
                })
                {}
              );

            # ormolu >= 0.5 needs ghc-lib-parser >= 8.10
            ghc-lib-parser = selfH.ghc-lib-parser_8_10_1_20200412;

            haskell-language-server = dontCheck
              (selfH.callCabal2nix
                "haskell-language-server"
                (builtins.fetchGit {
                  url = "https://github.com/haskell/haskell-language-server.git";
                  rev = "144457f37f9760fae19fb02e18f0471c0ba2204b";
                })
                {});

            # ghcide-0.1.0 needs 0.19.0, but Hackage has 0.20.0
            # haskell-language-server needs 0.22
            haskell-lsp       = selfH.callHackage "haskell-lsp"       "0.22.0.0" {};
            haskell-lsp-types = selfH.callHackage "haskell-lsp-types" "0.22.0.0" {};

            hie-bios = dontCheck (selfH.callHackage "hie-bios" "0.5.0" {});

            hlint = selfH.callHackage "hlint" "2.2.11" {};

            # need visibility: public support
            hpack = selfH.callHackage "hpack" "0.34.1" {};
            "hpack_0_34_2" = dontCheck (selfH.callCabal2nix
              "hpack"
              (self.pkgs.fetchFromGitHub {
                owner  = "sol";
                repo   = "hpack";
                rev = "a207c3eb3bcdf9279e82ba127f95745b3cea2377";
                sha256 = "sha256:1zvlah44rfn3pqha66x1hjc2xz2yszkkpxwwsv7lsig8pmziv4m8";
                # rev    = "0b1ac76a84dde0235bcfed1a6096aa8df71fc029";
                # sha256 = "sha256:09drg0ia778a0hgm9qfjg5r0z0lkn9wd9caf1z3alqq8dwyf10dl";
              })
              {});

            # "nothpack_0_34_2" = dontCheck (superH.callPackage
            #   ({ mkDerivation, aeson, base, bifunctors, bytestring, Cabal
            #    , containers, cryptonite, deepseq, directory, filepath, Glob, hspec
            #    , hspec-discover, http-client, http-client-tls, http-types, HUnit
            #    , infer-license, interpolate, mockery, pretty, QuickCheck
            #    , scientific, template-haskell, temporary, text, transformers
            #    , unordered-containers, vector, yaml
            #    }:
            #      mkDerivation {
            #        pname = "hpack";
            #        version = "0.34.2";
            #        sha256 = "0c0nnhg6yjcr6rmw2ffminjivjj8hd00cbimfkm6blxzmmxsv46i";
            #        isLibrary = true;
            #        isExecutable = true;
            #        libraryHaskellDepends = [
            #          # aeson
            #          base
            #          # bifunctors bytestring
            #          # Cabal
            #          #containers cryptonite
            #          # deepseq directory filepath Glob http-client http-client-tls
            #          # http-types infer-license pretty scientific text transformers
            #          # unordered-containers
            #          # vector
            #          yaml
            #        ];
            #        executableHaskellDepends = [
            #          # aeson base bifunctors bytestring Cabal containers cryptonite
            #          # deepseq directory filepath Glob http-client http-client-tls
            #          # http-types infer-license pretty scientific text transformers
            #          # unordered-containers vector yaml
            #        ];
            #        testHaskellDepends = [
            #          # aeson base bifunctors bytestring Cabal containers cryptonite
            #          # deepseq directory filepath Glob hspec http-client http-client-tls
            #          # http-types HUnit infer-license interpolate mockery pretty
            #          # QuickCheck scientific template-haskell temporary text transformers
            #          # unordered-containers vector yaml
            #        ];
            #        testToolDepends = [ hspec-discover ];
            #        description = "A modern format for Haskell packages";
            #        license = self.stdenv.lib.licenses.mit;
            #        hydraPlatforms = self.stdenv.lib.platforms.none;
            #      }) {});

            # haskell-language-server needs >= 0.5
            ormolu = selfH.callHackage "ormolu" "0.0.5.0" {};

            # haskell-lsp 0.22 needs lsp-test 0.11
            lsp-test = dontCheck (selfH.callHackage "lsp-test" "0.11.0.0" {});

            # needed by haskell-language-server, but tests fail
            monad-dijkstra = dontCheck superH.monad-dijkstra;

            # needed by ghcide
            opentelemetry = selfH.callHackage "opentelemetry" "0.4.0" {};

            # pantry = selfH.callHackage "pantry" "0.5.0.0" {};

            # haskell-language-server uses a fork of shake
            shake = dontCheck
              (selfH.callCabal2nix
                "shake"
                (self.pkgs.fetchFromGitHub {
                  owner  = "wz1000";
                  repo   = "shake";
                  rev    = "fb3859dca2e54d1bbb2c873e68ed225fa179fbef";
                  sha256 = "sha256:0sa0jiwgyvjsmjwpfcpvzg2p7277aa0dgra1mm6afh2rfnjphz8z";
                })
                {});

          };
    };

  "ghc883" =
    haskellOverlay {
      ghcVersion = "ghc883";
      makeHaskellPackagesOverlay = self: super: selfH: superH:
        let
          dontCheck = super.haskell.lib.dontCheck;
        in
          {

            # cabal-helper is not yet compatible with 3.2.0.0
            # cabal-install = selfH.callHackage "cabal-install" "3.0.0.0" {};
            # enforce Cabal 3.2.0.0 for hie
            Cabal = selfH.callHackage "Cabal" "3.0.1.0" {};
            # hie seems to care about Cabal being 3.2.0.0
            # cabal-helper = ...;

            # 3.0.2.0 seemingly never existed, this is 3.0.1.0 which never got released
            cabal-install = dontCheck
              (selfH.callCabal2nix
                "cabal-install"
                (self.pkgs.fetchFromGitHub {
                  owner  = "haskell";
                  repo   = "cabal";
                  rev    = "ef1d0c58994feff83cf8ac4d162c92d459541bfa";
                  sha256 = "sha256:183hqzys2bqnvd07wxd5zhdci7qwfxsvkhsxwy7zbnxfdjgfp634";
                } + "/cabal-install")
                {}
              );

            floskell = dontCheck superH.floskell;

            # current Hackage has old bound for haskell-lsp
            ghcide = dontCheck
              (selfH.callCabal2nix
                "ghcide"
                (self.pkgs.fetchFromGitHub {
                  owner  = "alanz";
                  repo   = "ghcide";
                  rev = "0db329a62375f086725571aa14e52f7b9f85ac3b";
                  sha256 = "sha256:02249zask2c2rr2npw7aj0ihmwj9a7kxzg38ibrb9r06wq93lrj7";
                })
                {}
              );

            # ormolu >= 0.5 needs ghc-lib-parser >= 8.10
            ghc-lib-parser = selfH.ghc-lib-parser_8_10_1_20200412;

            haskell-language-server = dontCheck
              (selfH.callCabal2nix
                "haskell-language-server"
                (builtins.fetchGit {
                  url = "https://github.com/haskell/haskell-language-server.git";
                  rev = "144457f37f9760fae19fb02e18f0471c0ba2204b";
                })
                {});

            # ghcide-0.1.0 needs 0.19.0, but Hackage has 0.20.0
            # haskell-language-server needs 0.22
            haskell-lsp       = selfH.callHackage "haskell-lsp"       "0.22.0.0" {};
            haskell-lsp-types = selfH.callHackage "haskell-lsp-types" "0.22.0.0" {};

            hie-bios = dontCheck (selfH.callHackage "hie-bios" "0.5.0" {});

            hlint = selfH.callHackage "hlint" "2.2.11" {};

            # need visibility: public support
            # hpack = selfH.callHackage "hpack" "0.34.1" {};
            hpack = (selfH.callCabal2nix
              "hpack"
              (self.pkgs.fetchFromGitHub {
                owner  = "sol";
                repo   = "hpack";
                rev    = "1dc82f836d1261310c9db322a9788c73c62e6193";
                sha256 = "sha256:1g8na5vqki8z3vkjyg6dk97x7nzlyzj9m753xf4bqjhsd0gdv68r";
              })
              {});

            # haskell-language-server needs >= 0.5
            ormolu = selfH.callHackage "ormolu" "0.0.5.0" {};

            # haskell-lsp 0.22 needs lsp-test 0.11
            lsp-test = dontCheck (selfH.callHackage "lsp-test" "0.11.0.0" {});

            # needed by haskell-language-server, but tests fail
            monad-dijkstra = dontCheck superH.monad-dijkstra;

            # needed by ghcide
            opentelemetry = selfH.callHackage "opentelemetry" "0.4.0" {};

            # pantry = selfH.callHackage "pantry" "0.5.0.0" {};

            # haskell-language-server uses a fork of shake
            shake = dontCheck
              (selfH.callCabal2nix
                "shake"
                (self.pkgs.fetchFromGitHub {
                  owner  = "wz1000";
                  repo   = "shake";
                  rev    = "fb3859dca2e54d1bbb2c873e68ed225fa179fbef";
                  sha256 = "sha256:0sa0jiwgyvjsmjwpfcpvzg2p7277aa0dgra1mm6afh2rfnjphz8z";
                })
                {});

          };
    };

  "ghc8101" =
    haskellOverlay {
      ghcVersion = "ghc8101";
      makeHaskellPackagesOverlay = self: super: selfH: superH:
        let
          dontCheck = super.haskell.lib.dontCheck;
        in
          {

            ghc-lib-parser = selfH.ghc-lib-parser_8_10_1_20200412;
            ormolu = selfH.callHackage "ormolu" "0.0.5.0" {};

          };
    };

}
