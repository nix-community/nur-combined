# repo: <https://github.com/Siriusmart/youtube-tui>
# troubleshooting:
# - "Invalid Request: This helps protect our community."
#   - choose a different invidious instance
#     - <https://docs.invidious.io/instances/>
#     - <https://farside.link/>
#   - <https://github.com/Siriusmart/youtube-tui/issues/57>
# thumbnail `images` options:
# - None
# - Sixels
# - HalfBlocks
# `write_config` options:
# - Dont
# - Must
# - Try
{ pkgs, ... }:
{
  sane.programs.youtube-tui = {
    packageUnwrapped = pkgs.youtube-tui.overrideAttrs (upstream: {
      # give the package a .desktop item.
      nativeBuildInputs = (upstream.nativeBuildInputs or []) ++ [
        pkgs.copyDesktopItems
      ];
      desktopItems = (upstream.desktopItems or []) ++ [
        (pkgs.makeDesktopItem {
          name = "youtube-tui";
          exec = "youtube-tui";
          desktopName = "YouTube TUI";
          genericName = "YouTube Client";
          icon = "multimedia-player";
          terminal = true;
          type = "Application";
        })
      ];
    });
    fs.".config/youtube-tui/main.yml".symlink.text = ''
      allow_unicode: true
      image_index: 4
      images: Sixels
      invidious_instance: https://yt.artemislena.eu
      legacy_input_handling: false
      message_bar_default: ready
      mouse_support: true
      provider: YouTube
      refresh_after_modifying_search_filters: true
      shell: sh
      write_config: Dont
      env:
        browser: xdg-open
        download-path: ~/tmp/youtube-tui/%(title)s-%(id)s.%(ext)s
        save-path: ~/tmp/youtube-tui/saved/
        terminal-emulator: alacritty -e
        video-player: xdg-open
        youtube-downloader: yt-dlp
      limits:
        commands_history: 75
        search_history: 75
        watch_history: 50
      syncing:
        download_images: true
        sync_channel_cooldown_secs: 86400
        sync_channel_info: true
        sync_videos_cooldown_secs: 600
    '';
    sandbox.net = "all";
    sandbox.extraHomePaths = [
      # ".config/youtube-tui"  #< it populates its own config, other than just main.yml
      "tmp/youtube-tui"
    ];
    sandbox.whitelistDbus.user = true;  #< TODO: reduce  #< xdg-open via portal
  };
}
