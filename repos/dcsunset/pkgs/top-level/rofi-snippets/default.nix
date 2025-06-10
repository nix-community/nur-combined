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
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "DCsunset";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-PVMhUhdwm8/4W1zVylaj5T3Q1ppszN1ZzGXsjZe8xw4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs =
    [ glib cairo pango libxkbcommon ]
    ++ lib.optionals (builtins.elem "x11" features) [ xdotool ];

  useFetchCargoVendor = true;
  cargoHash = "sha256-O6/M+H8Btj3P7Svr409KCA9BCXYj+BVzFL9IJ+pmLdA=";

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
