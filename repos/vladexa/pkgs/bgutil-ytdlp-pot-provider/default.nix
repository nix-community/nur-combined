{ pkgs, ... }:
let
  version = "1.2.2";
  meta = {
    description = "Proof-of-origin token provider plugin for yt-dlp";
    homepage = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider";
    license = pkgs.lib.licenses.gpl3Plus;
    maintainers = [
      {
        email = "vgrechannik@gmail.com";
        name = "Vladislav Grechannik";
        github = "VlaDexa";
        githubId = 52157081;
      }
    ];
  };
in
{
  server = pkgs.callPackage ./server.nix {
    inherit version;
    meta = {
      inherit (meta)
        description
        homepage
        license
        maintainers
        ;
      mainProgram = "bgutil-ytdlp-pot-provider";
    };
  };
  plugin = pkgs.callPackage ./plugin.nix { inherit version meta; };
}
