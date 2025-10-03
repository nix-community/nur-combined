{ ffmpeg, lib }:
ffmpeg.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    # https://github.com/nilaoda/Blog/discussions/81
    # https://gitee.com/openharmony/third_party_ffmpeg/pulls/49/files
    ./ffmpeg-libavcodec-av3a.patch
    # https://gitee.com/openharmony/third_party_ffmpeg/pulls/128/files
    ./ffmpeg-libavformat-av3a.patch
  ];

  meta = old.meta // {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "FFmpeg with Lan Tian modifications";
  };
})
