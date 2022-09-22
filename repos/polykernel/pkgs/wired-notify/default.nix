{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, dbus
, cairo
, pango
, xorg
}:

rustPlatform.buildRustPackage rec {
  pname = "wired-notify";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "Toqozz";
    repo = pname;
    rev = "refs/tags/${version}";
    sha256 = "sha256-Z+y4dxNfn7OCTw6dFOVnEvEaq9FS6HRaIomzfdpVfK8=";
  };

  cargoHash = "sha256-eWjX2DdRlXHBzzjFS97++zFJjlvNRu/cR0Li6k3y8z8=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    cairo
    pango
    xorg.libX11
    xorg.libXi
    xorg.libXrandr
    xorg.libXcursor
    xorg.libXScrnSaver
  ];

  postInstall = ''
    # /usr/bin/wired doesn't exist, here, because the binary will be somewhere in /nix/store,
    # so this fixes the bin path in the systemd service and writes the updated file to the output dir.
    mkdir -p $out/usr/lib/systemd/system
    substitute ./wired.service $out/usr/lib/systemd/system/wired.service --replace /usr/bin/wired $out/bin/wired
    # install example/default config files to etc/wired -- Arch packages seem to use etc/{pkg} for this,
    # so there's precedent
    install -Dm444 -t $out/etc/wired wired.ron wired_multilayout.ron
  '';

  meta = with lib; {
    description = "Lightweight notification daemon with highly customizable layout blocks, written in Rust.";
    homepage = "https://github.com/Toqozz/wired-notify";
    license = licenses.mit;
    maintainers = [ maintainers.polykernel ];
    platforms = platforms.linux;
  };
}
