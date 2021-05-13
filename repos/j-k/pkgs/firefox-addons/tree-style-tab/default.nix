{ lib, fetchFirefoxAddon }:

fetchFirefoxAddon {
  name = "tree-style-tab";
  url = "https://addons.mozilla.org/firefox/downloads/file/3772067/tree_style_tab_-3.8.1-fx.xpi";
  sha256 = "sha256-owJMmoA1ZWQMY9+hNbD1m7PyW8wDH8Vjj8a9nS+U/AY=";

  # meta = with lib; {
  #   https://github.com/piroor/treestyletab/releases/download/3.7.3/treestyletab-we.xpi
  #   https://github.com/piroor/treestyletab/
  #   homepage = "https://piro.sakura.ne.jp/xul/_treestyletab.html.en/";
  #   changelog = "https://piro.sakura.ne.jp/xul/_treestyletab.html.en#history/"
  #   description = "Show tabs like a tree";
  #   longDescription = ''
  #     This is a Firefox add-on which provides the ability to operate tabs as
  #     "tree".

  #     New tabs opened from the current tab are automatically organized as
  #     "children" of the current. Such "branches" are easily folded (collapsed)
  #     by clicking on down on the arrow shown in the "parent" tab, so you don't
  #     need to suffer from too many visible tabs anymore. If you want, you can
  #     restructure the tree via drag and drop.
  #   '';
  #   license = licenses.mpl20;
  #   maintainers = with maintainers; [ jk ];
  # };
}
