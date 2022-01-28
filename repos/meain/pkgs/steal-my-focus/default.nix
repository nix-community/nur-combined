{ pkgs, lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-stealmyfocus";
  uuid = "focus-my-window@varianto25.com";
  version = "3eab84ea45a09ee42207c922260ae60cf03acb2c";

  src = fetchFromGitHub {
    repo = pname;
    # owner = "v-dimitrov";
    owner = "meain";
    rev = version;
    sha256 = "sha256-7OcRk5RRQ28avvh93W8k2iobUD6/2jQGqA6VWXLWi/E=";
  };
  buildCommand = ''
    mkdir -p $out/share/gnome-shell/extensions/
    cp -r -T $src $out/share/gnome-shell/extensions/${uuid}
  '';
  meta = {
    description = "Open app instead of showing that the app is ready";
    homepage = "https://github.com/meain/${pname}";
  };
  passthru = {
    extensionPortalSlug = "gnome-shell-extension-steal-my-focus";
    # Store the extension's UUID, because we might need it at some places
    extensionUuid = uuid;
  };
}
