{ theme }:

{
  inherit theme;
  editor = {
    bufferline = "multiple";
    cursorline = true;
    cursor-shape = {
      insert = "bar";
      normal = "block";
      select = "underline";
    };
    indent-guides = {
      character = "|";
      render = true;
    };
    line-number = "relative";
    lsp = {
      display-messages = true;
    };
    soft-wrap = {
      enable = true;
      wrap-indicator = "↪ ";
    };
  };
}
