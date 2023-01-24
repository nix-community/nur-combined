{
  stdenv,
  lib,
  fetchFromGitHub,
  rustPlatform,
  writeTextFile,
  pkg-config,
  libxkbcommon,
}:

rustPlatform.buildRustPackage rec {
  pname = "swww";
  version = "0.6.0";
  
  src = fetchFromGitHub {
    owner = "Horus645";
    repo = "${pname}";
    rev = "v${version}";
    hash = "sha256-9qTKaLfVeZD8tli7gqGa6gr1a2ptQRj4sf1XSPORo1s=";
  };
  
  cargoHash = "sha256-OWe+r8Vh09yfMFBjVH66i+J6RtHo1nDva0m1dJPZ4rE=";
  
  nativeBuildInputs = [ pkg-config ];
  
  buildInputs = [ libxkbcommon ];
  
  # see https://github.com/Horus645/swww/issues/74
  postPatch = ''sed -i 's|let img = match image::open(&request.path)|let reader = image::io::Reader::open(\&request.path).expect("").with_guessed_format().expect("");let img = match reader.decode()|g' src/daemon/processor/mod.rs'';
  
  doCheck = false;
  
  meta = with lib; {
    description = "A Solution to your Wayland Wallpaper Woes. ";
    homepage = "https://github.com/Horus645/${pname}";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}


