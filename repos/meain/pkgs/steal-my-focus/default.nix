{ pkgs, lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-steal-my-focus";
  uuid = "focus-my-window@varianto25.com";
  version = "3eab84ea45a09ee42207c922260ae60cf03acb2c";

  src = fetchFromGitHub {
    repo = "gnome-shell-extension-stealmyfocus";
    # owner = "v-dimitrov";
    owner = "meain";
    rev = version;
    sha256 = "sha256:1wcbsrr5k58fm0339nmz7r81nans4ipxszgqpqd6yhsijj9i3rzc";
  };
  buildCommand = ''
    mkdir -p $out/share/gnome-shell/extensions/
    cp -r -T $src $out/share/gnome-shell/extensions/${uuid}
  '';
  meta = {
    description = "Open app instead of showing that the app is ready";
    homepage = "https://github.com/v-dimitrov/${uuid}";
  };
  passthru = {
    extensionPortalSlug = "gnome-shell-extension-steal-my-focus";
    # Store the extension's UUID, because we might need it at some places
    extensionUuid = uuid;
  };
}
