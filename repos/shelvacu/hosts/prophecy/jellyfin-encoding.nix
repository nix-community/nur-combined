{ config, ... }:
{
  hardware.graphics.enable = true;
  users.users.${config.services.jellyfin.user}.extraGroups = [
    "video"
    "render"
  ];

  services.declarative-jellyfin.encoding = {
    enableHardwareEncoding = true;
    hardwareAccelerationType = "vaapi";

    hardwareDecodingCodecs = [
      "h264"
      "hevc"
      "mpeg2video"
      "vc1"
      "vp8"
      "vp9"
      "av1"
    ];
    allowAv1Encoding = true;
    allowHevcEncoding = true;
    deinterlaceDoubleRate = true;
    enableDecodingColorDepth10Hevc = true;
    enableDecodingColorDepth10HevcRext = true;
    enableDecodingColorDepth10Vp9 = true;

    enableSegmentDeletion = true;
    enableTonemapping = true;
    enableVppTonemapping = true;

    enableThrottling = true;
    throttleDelaySeconds = 60 * 10;
  };
}
