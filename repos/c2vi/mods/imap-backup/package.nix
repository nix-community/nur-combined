{ pkgs
, bundlerEnv
, ruby
, stdenv
, lib
, fetchFromGitHub
}:
let
  ruby-nix-flake = builtins.getFlake "github:inscapist/ruby-nix/81709ec61d212dce4d45615b5865f7381e4d1c2e";
  rubyNix = ruby-nix-flake.outputs.lib pkgs;
  myEnv = rubyNix {
    name = "imap-backup-env";
    gemset = ./gemset.nix;
  };

  src = fetchFromGitHub {
    owner = "joeyates";
    repo = "imap-backup";
    rev = "v${version}";
    sha256 = "sha256-FJujesExQ4H+RoRUXec5Akp1z1f5nbmMj7cQSk4nkgQ=";
  };
  
  version = "15.0.2";
in pkgs.writeShellApplication rec {
  name = "imap-backup";

  text = ''
    ${myEnv.ruby}/bin/ruby ${src}/bin/imap-backup "$@"
  '';

  meta = with lib; {
    description = "Backup and Migrate IMAP Email Accounts ";
    longDescription = ''
      from: https://github.com/joeyates/imap-backup
    '';
    homepage = "https://github.com/joeyates/imap-backup";
    #maintainers = [ ];
    platforms = platforms.all;
  };
}
