{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
# 让 niri 的浮动窗跨所有 workspace 常驻（niri 原生没有 sticky/pin，见
# https://github.com/niri-wm/niri/issues/932）。以 daemon 跑，按 -app-id / -title
# 正则选窗。这里用来把 org-dock 那个 emacs frame 钉在每个工作区都在。
buildGoModule (finalAttrs: {
  pname = "niri-float-sticky";
  version = "0-unstable-2026-05-12";

  src = fetchFromGitHub {
    owner = "probeldev";
    repo = "niri-float-sticky";
    rev = "b4805593eda05fc61e4cb88cfced9dd39913216e";
    hash = "sha256-786xACvNk6ZE6l40gQ7wRsgqGp64Z4MseMX7gzMMNtg=";
  };

  vendorHash = "sha256-GqbY3qkPjMxyW9RTsN9hkgM3Bda6A8rb2kR4YQW1nFI=";

  ldflags = [ "-s" "-w" ];

  meta = {
    mainProgram = "niri-float-sticky";
    description = "Make niri floating windows sticky across all workspaces";
    homepage = "https://github.com/probeldev/niri-float-sticky";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
