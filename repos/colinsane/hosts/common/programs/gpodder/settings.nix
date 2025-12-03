{
  auto = {
    cleanup.days = 7;
    cleanup.played = false;
    cleanup.unfinished = true;
    cleanup.unplayed = false;
    retries = 3;
    update.enabled = false;
    # update.frequency = 20;
  };
  check_connection = false;
  downloads.chronological_order = true;
  extensions.enabled = [
    # gpodder's python-only youtube-dl module doesn't support DRM'd videos,
    # so *always* shell out to yt-dlp
    "youtube-dl"
  ];
  extensions.youtube-dl = {
    embed_subtitles = false;
    # manage_channel = true: uses `yt-dlp` to fetch the list of episodes for a channel.
    # manage_downloads = true: uses `yt-dlp` to download each individual episode.
    # XXX(2025-07-30): `manage_channel = false` otherwise yt-dlp hangs the refresh operation (it gets stuck on age verification?)
    #   `manage_downloads = true` because only yt-dlp can handle DRM'd video; native gpodder cannot.
    manage_channel = false;
    manage_downloads = true;
  };
  limit.bandwidth.enabled = false;
  # limit.bandwidth.kbps = 500.0;
  limit.downloads.concurrent = 2;
  limit.downloads.concurrent_max = 16;
  limit.downloads.enabled = true;
  limit.episodes = 200;
  # player.audio = "default";
  # player.video = "default";
  software_update.check_on_startup = false;
  software_update.interval = 0;
  software_update.last_check = 0;
  # "ui": {
  #   "cli": {
  #     "colors": true
  #   },
  #   "gtk": {
  #     "color_scheme": "light",
  #     "download_list": {
  #       "remove_finished": true
  #     },
  #     "episode_list": {
  #       "always_show_new": true,
  #       "columns": 6,
  #       "ctrl_click_to_sort": false,
  #       "descriptions": true,
  #       "right_align_released_column": false,
  #       "show_released_time": false,
  #       "trim_title_prefix": true,
  #       "view_mode": 1
  #     },
  #     "find_as_you_type": true,
  #     "html_shownotes": true,
  #     "live_search_delay": 200,
  #     "new_episodes": "show",
  #     "only_added_are_new": false,
  #     "podcast_list": {
  #       "all_episodes": true,
  #       "hide_empty": false,
  #       "sections": true,
  #       "view_mode": 1
  #     },
  #     "search_always_visible": false,
  #     "state": {
  #       "channel_editor": {
  #         "height": -1,
  #         "maximized": false,
  #         "width": -1,
  #         "x": -1,
  #         "y": -1
  #       },
  #       "config_editor": {
  #         "height": 450,
  #         "maximized": false,
  #         "width": 750,
  #         "x": 0,
  #         "y": 0
  #       },
  #       "episode_selector": {
  #         "height": 1136,
  #         "maximized": false,
  #         "width": 958,
  #         "x": 20,
  #         "y": 20
  #       },
  #       "episode_window": {
  #         "height": 400,
  #         "maximized": false,
  #         "width": 500,
  #         "x": -1,
  #         "y": -1
  #       },
  #       "export_to_local_folder": {
  #         "height": 400,
  #         "maximized": false,
  #         "width": 500,
  #         "x": -1,
  #         "y": -1
  #       },
  #       "main_window": {
  #         "episode_column_order": [],
  #         "episode_column_sort_id": 12,
  #         "episode_column_sort_order": false,
  #         "episode_list_size": 200,
  #         "height": 1137,
  #         "maximized": false,
  #         "paned_position": 200,
  #         "width": 1920,
  #         "x": 20,
  #         "y": 20
  #       },
  #       "podcastdirectory": {
  #         "height": -1,
  #         "maximized": false,
  #         "width": -1,
  #         "x": -1,
  #         "y": -1
  #       },
  #       "preferences": {
  #         "height": 1137,
  #         "maximized": false,
  #         "width": 1920,
  #         "x": 0,
  #         "y": 0
  #       }
  #     },
  #     "toolbar": false
  #   }
  # },
  # "vimeo": {
  #   "fileformat": "720p"
  # },
  # "youtube": {
  #   "preferred_fmt_id": 18,
  #   "preferred_fmt_ids": [],
  #   "preferred_hls_fmt_id": 93,
  #   "preferred_hls_fmt_ids": []
  # }
}
