{ pkgs, stdenv, lib, buildFishPlugin }:

self: super: {
  fish-fasd = super.fish-fasd.overrideAttrs (old: {
    dependencies = [ pkgs.fasd ];
  });

  thefuck = let
    src = pkgs.runCommand "fuck.fish" {} ''
      mkdir -p $out/functions
      ${pkgs.fish}/bin/fish -c "${pkgs.thefuck}/bin/thefuck --alias > $out/functions/fuck.fish"
      chmod +x $out/functions/fuck.fish
    '';
  in buildFishPlugin {
    pname = "thefuck";
    version = lib.getVersion pkgs.thefuck;
    inherit src;
    dependencies = [ pkgs.thefuck ];
  };
}
