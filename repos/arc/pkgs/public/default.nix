{
  i3gopher = import ./i3gopher;
  tamzen = import ./tamzen.nix;
  paswitch = import ./paswitch.nix;
  base16-shell = import ./base16-shell.nix;
  clip = import ./clip.nix;
  nvflash = import ./nvflash.nix;
  nvidia-vbios-vfio-patcher = import ./nvidia-vbios-vfio-patcher;
  nvidia-capture-sdk = import ./nvidia-capture-sdk.nix;
  edfbrowser = import ./edfbrowser;
  mdloader = import ./mdloader.nix;
  muFFT = import ./mufft.nix;
  libjaylink = import ./libjaylink.nix;
  openocd-git = import ./openocd-git.nix;
  gst-jpegtrunc = import ./gst-jpegtrunc.nix;
  gst-rtsp-launch = import ./gst-rtsp-launch;
}
// (import ./droid.nix)
// (import ./weechat)
// (import ./looking-glass)
// (import ./crates)
// (import ./linux)
// (import ./ryzen-smu)
// (import ./matrix)
// (import ./pass)
// (import ../git)
