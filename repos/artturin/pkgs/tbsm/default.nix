{ stdenv, lib, fetchFromGitHub, bash }:
# Needs a module so that it detects sessions


stdenv.mkDerivation rec {
  pname = "tbsm";
  version = "unstable-2019-03-19";

  src = fetchFromGitHub {
    owner = "loh-tar";
    repo = "tbsm";
    rev = "8f7ce7a6e4b5a4b9ab2109cbadb2f133bbf4cf03";
    sha256 = "0av8jfjjlkv8mhpignwc61c8ndmzgbdadrkqfivf5qpbxm9kl7zg";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "/usr/bin" "$out/bin" \
      --replace "/etc/xdg" "$out/etc/xdg" \
      --replace "/usr/share" "$out/share"

    substituteInPlace src/tbsm \
      --replace "/etc/xdg" "$out/etc/xdg"
  '';

  meta = with lib; {
    homepage = "https://github.com/loh-tar/tbsm/tree/8f7ce7a6e4b5a4b9ab2109cbadb2f133bbf4cf03";
    description = " A pure bash session or application launcher";
    platforms = platforms.linux;
  };
}
