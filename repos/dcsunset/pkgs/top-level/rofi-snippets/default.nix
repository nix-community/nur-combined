{
  lib,
  fetchFromGitHub,
  rustPlatform,
	pkg-config,
  glib,
  cairo,
  pango,
  xdotool,
  libxkbcommon,

  features ? [ "wayland" "x11" ],
}:

rustPlatform.buildRustPackage rec {
  pname = "rofi-snippets";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ePlvVLKe0Pb+F3wLV1vHAxlMQeOuvdndWB0jCu71i+A=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [ glib cairo pango libxkbcommon ]
    ++ lib.optionals (builtins.elem "x11" features) [ xdotool ];

  cargoHash = "sha256-LdsXbJL6J04sI+9w0zkyV/bGQz2X5nC1uQ/dRM2voww=";

  buildNoDefaultFeatures = true;
  buildFeatures = features;

  # move lib to lib/rofi
  postInstall = ''
    mkdir -p $out/lib/rofi
    mv $out/lib/*.so $out/lib/rofi/
  '';

  meta = with lib; {
    description = " A Rofi plugin to select snippets and simulate keyboard input of snippet content.";
    homepage = "https://github.com/DCsunset/${pname}";
    license = licenses.agpl3Only;
  };
}
