{ pkgs, lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-stealmyfocus";
  uuid = "focus-my-window@varianto25.com";
  version = "e60a5acf24841e770ce4ed8b3b6704bb1bcbb8c5";
  owner = "v-dimitrov";

  src = fetchFromGitHub {
    repo = pname;
    inherit owner;
    rev = version;
    sha256 = "sha256-7OcRk5RRQ28avvh93W8k2iobUD6/2jQGqA6VWXLWi/E=";
  };
  patches = [ ./gnome40.patch ];
  buildCommand = ''
    mkdir -p $out/share/gnome-shell/extensions/
    cp -r -T $src $out/share/gnome-shell/extensions/${uuid}
  '';
  meta = {
    description = "Open app instead of showing that the app is ready";
    homepage = "https://github.com/${owner}/${pname}";
  };
  passthru = {
    extensionPortalSlug = "gnome-shell-extension-steal-my-focus";
    # Store the extension's UUID, because we might need it at some places
    extensionUuid = uuid;
  };
}
