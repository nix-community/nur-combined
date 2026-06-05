{ ... }:
{
  sane.programs.xdg-mime = {
    # `mimetype` provides better mime associations than `file`
    # - see: <https://github.com/NixOS/nixpkgs/pull/285233#issuecomment-1940828629>
    sandbox.autodetectCliPaths = "existing";
    sandbox.extraHomePaths = [
      ".local/share/applications"  #< speculative
    ];
    suggestedPrograms = [
      # "perlPackages.FileMimeInfo"
      "mimetype"
      # "mimeopen"  #< optional, unclear what benefit
    ];
  };
}

