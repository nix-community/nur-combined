{ pkgs
, lib
, config
, ...
}:
let
  repo = pkgs.fetchFromGitHub {
    owner = "StevenBlack";
    repo = "hosts";
    rev = "c66c4aa05a95669943eb3b8f68ba3d359825c4b9"; # master
    sha256 = "13m2f2v2aqj1ggrg2d9ichm8wkmwg8d9c61g08a4b6cjq57qk7mh";
  };
in
{
  options.networking.adblock = {
    enable = lib.mkEnableOption "Enable hosts ad-blocking";
    recipe = lib.mkOption {
      type = lib.types.listOf (lib.types.enum [ "fakenews" "gambling" "porn" "social" ]);
      default = [ ];
    };
    allowedHosts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };
  config = lib.mkIf config.networking.adblock.enable (
    let
      recipe = [ "basic" ] ++ config.networking.adblock.recipe;
      myHosts = pkgs.runCommand "my-hosts" { } ''
        ${pkgs.perl}/bin/perl -e '
          my $allowed = ${builtins.toJSON config.networking.adblock.allowedHosts};
          my @allowedRegex = map { qr/(?:\A|.*[.])$_$/ } map { quotemeta $_ } @$allowed;
          my $listStarted = 0;
          LINE: foreach (<>) {
            $listStarted = 1 if /^# Start StevenBlack$/;
            next LINE if $listStarted == 0;
            s/\s*#.*$//; # Remove comments
            next LINE if /^$/; # Skip empty lines
            s/^\s*//; s/\s*$//; s/\s+/ /g; # Normalize whitespace
            s/^\Q0.0.0.0\E\s+//; # Remove 0.0.0.0 prefix
            foreach my $a (@allowedRegex) {
              next LINE if /$a/;
            }
            print "0.0.0.0 $_\n";
          }
        ' ${repo}/hosts ${builtins.concatStringsSep " " (builtins.map (list: "${repo}/alternates/${list}-only/hosts") recipe)} > $out
      '';
    in
    {
      networking.extraHosts = builtins.readFile myHosts.outPath;
    }
  );
}
