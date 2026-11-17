{
  lib,
  vimUtils,
  sources,
  source ? sources.pi-nvim,
}:

vimUtils.buildVimPlugin {
  inherit (source) pname version src;

  nvimRequireCheck = "pi";

  meta = {
    description = "Use the pi coding agent without leaving Neovim";
    homepage = "https://github.com/alex35mil/pi.nvim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
  };
}
