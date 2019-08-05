let
  defaultChannel = "unstable/nixos-19.09pre173349.07b42ccf2de";
  defaultSha256 = "0lkv2957by2jnszl1l1nzns0a9j1hq73y0s5jjzs0x2k88qyrcwk";
  packages = {
    programsDatabase = { stdenvNoCC, fetchurl, channel ? defaultChannel, sha256 ? defaultSha256 }: stdenvNoCC.mkDerivation {
      # example channel: unstable/nixos-19.09pre173349.07b42ccf2de
      name = "programs.sqlite";

      src = fetchurl {
        url = "http://releases.nixos.org/nixos/${channel}/nixexprs.tar.xz";
        inherit sha256;
      };

      buildCommand = ''
        tar -xJf $src --strip-components=1 --occurrence --wildcards 'nixos*/programs.sqlite'
        install -m0644 programs.sqlite $out
      '';
    };
    commandNotFound = { lib, substituteAll, programsDatabase, perl, perlPackages }: substituteAll {
      name = "command-not-found";
      dir = "bin";
      src = <nixpkgs/nixos/modules/programs/command-not-found/command-not-found.nix>;
      isExecutable = true;
      inherit perl;
      dbPath = programsDatabase;
      perlFlags = lib.concatStrings (map (path: "-I ${path}/lib/perl5/site_perl ")
        [ perlPackages.DBI perlPackages.DBDSQLite perlPackages.StringShellQuote ]);

      meta.broken = perl.stdenv.isDarwin; # https://github.com/NixOS/nixpkgs/pull/64157 seems to have broken string shellquote
    };
  };
in packages
