{
  fetchFromGitHub,
  lib,
  libnotify,
  tmuxPlugins,
}:
tmuxPlugins.mkTmuxPlugin rec {
  pluginName = "tmux-notify";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "rickstaa";
    repo = "tmux-notify";
    tag = "v${version}";
    hash = "sha256-J7RNQEfeEtWFe9AJ4dHN2d/sZvs0EtPwPG7f5DZg+tA=";
  };

  rtpFilePath = "tnotify.tmux";

  postInstall = ''
    find $target -type f -exec sed -i 's|notify-send |${lib.getExe libnotify} |g' {} +
  '';

  meta = {
    homepage = "https://github.com/rickstaa/tmux-notify";
    description = "Tmux plugin to notify you when processes are finished";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
    maintainers = [ lib.maintainers.skyesoss ];
  };
}
