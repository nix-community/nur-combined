{ vimUtils
, fetchFromGitHub
, lib
,
}:
vimUtils.buildVimPlugin {
  name = "wiki.vim";
  src = fetchFromGitHub {
    owner = "lervag";
    repo = "wiki.vim";
    rev = "d53f4f4b243147fc0ed9e89a9c8ade89abb5480f";
    hash = "sha256-1NuEqKaNO0nvxq5kKjLNGtNeGyVh8g7LM9X7Wyy7h1Q=";
  };

  meta = with lib; {
    description = "A Vim plugin for writing and maintaining a personal wiki";
    longDescription = ''
      Wiki.vim is a Vim plugin for writing and maintaining a personal wiki.

      The plugin was initially based on vimwiki, but it is written mostly from scratch and is based on a more "do one thing and do it well" philosophy.

      Note: wiki.vim is not a filetype plugin. It is designed to be used with filetype plugins, e.g. dedicated Markdown plugins. Users are adviced to read :help wiki-intro-plugins for a list of plugins that work well with wiki.vim.
    '';
    homepage = "https://github.com/lervag/wiki.vim";
    license = licenses.mit;
    maintainers = with maintainers; [ minion3665 ];
  };
}
