{
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      rust = {
        symbol = " ";
      };
    };
  };
  my.programs.starship.enableFishAsyncPrompt = true;
}
