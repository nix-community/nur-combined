{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "retro-aim-server";
  version = "0.23.0";

  src = fetchFromGitHub {
    owner = "mk6i";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-i3HlVIsPwkJVjlNEYtll0XnKLxLmoHqXxOmyKjYOiDw=";
  };

  vendorHash = "sha256-+7qeNjuCfSkA1mPU4sx8PqytKWO0o8vbLfvmg2C0so8=";

  meta = with lib; {
    description = "Self-hostable instant messaging server compatible with classic AIM and ICQ clients";
    homepage = "https://github.com/mk6i/retro-aim-server";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
