# This file was generated by nvfetcher, please do not modify it manually.
{
  fetchgit,
  fetchurl,
  fetchFromGitHub,
  dockerTools,
}:
{
  firefox-gnome-theme = {
    pname = "firefox-gnome-theme";
    version = "c1d082e47cb38b9e8d8d6899398f3bae51a72c34";
    src = fetchFromGitHub {
      owner = "rafaelmardojai";
      repo = "firefox-gnome-theme";
      rev = "c1d082e47cb38b9e8d8d6899398f3bae51a72c34";
      fetchSubmodules = false;
      sha256 = "sha256-Hf2NK58bTV1hy6FxvKpyNzm59tyMPzDjc8cGcWiTLyQ=";
    };
    date = "2024-11-30";
  };
  iosevka-zt = {
    pname = "iosevka-zt";
    version = "31.2.0";
    src = fetchurl {
      url = "https://github.com/zzzsyyy/Iosevka/releases/download/v31.2.0/Iosevka-31.2.0.txz";
      sha256 = "sha256-9rL+gEuWqIYlTJ8GA6ylVEgDYj02HfQ08Jic8WWmhYA=";
    };
  };
  librime-lua = {
    pname = "librime-lua";
    version = "b210d0cfbd2a3cc6edd4709dd0a92c479bfca10b";
    src = fetchFromGitHub {
      owner = "hchunhui";
      repo = "librime-lua";
      rev = "b210d0cfbd2a3cc6edd4709dd0a92c479bfca10b";
      fetchSubmodules = false;
      sha256 = "sha256-ETjLN40G4I0FEsQgNY8JM4AInqyb3yJwEJTGqdIHGWg=";
    };
    date = "2024-11-02";
  };
  lxgw-wenkai-screen = {
    pname = "lxgw-wenkai-screen";
    version = "v1.501";
    src = fetchurl {
      url = "https://github.com/lxgw/LxgwWenKai-Screen/releases/download/v1.501/LXGWWenKaiScreen.ttf";
      sha256 = "sha256-em3uh53neN8v1ueiw1rWVtC0bteD7IG3X1g9tkjBRJA=";
    };
  };
  plangothic = {
    pname = "plangothic";
    version = "V1.9.5766";
    src = fetchFromGitHub {
      owner = "Fitzgerald-Porthmouth-Koenigsegg";
      repo = "Plangothic-Project";
      rev = "V1.9.5766";
      fetchSubmodules = false;
      sha256 = "sha256-wdDhKINEHNrayliUwOXNg0jIg4/W3TH9VjETblJGqvE=";
    };
  };
  rime-ice = {
    pname = "rime-ice";
    version = "ed191350b20a0074d177c9431fcb985ba193ef2b";
    src = fetchFromGitHub {
      owner = "iDvel";
      repo = "rime-ice";
      rev = "ed191350b20a0074d177c9431fcb985ba193ef2b";
      fetchSubmodules = false;
      sha256 = "sha256-+6Xci9S/5YY7ykYpv9SxtmNWWjOzqYatlGPTIY/FEqY=";
    };
    date = "2024-11-30";
  };
}
