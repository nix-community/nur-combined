{ lib , stdenv,
cacert,
webkitgtk,
nodejs_18, libiconv,rustc, cargo,fetchFromGitHub,  darwin, ... }: 

stdenv.mkDerivation rec {
  pname = "postflop-solver";
  version = "v0.2.7";

  src = fetchFromGitHub {
    owner = "b-inary";
    repo = "desktop-postflop";
    rev = "${version}";
    sha256 = "sha256-pOPxNHM4mseIuyyWNoU0l+dGvfURH0+9+rmzRIF0I5s=";
  };


  nativeBuildInputs = [ 
rustc cargo
  ];

  buildInputs = [
    libiconv
    nodejs_18

    #webkitgtk

    darwin.apple_sdk.frameworks.Carbon
    darwin.apple_sdk.frameworks.Cocoa
    darwin.apple_sdk.frameworks.Security
          darwin.apple_sdk.frameworks.SystemConfiguration
    darwin.apple_sdk.frameworks.WebKit

	  cacert
  ];

	patches = [
		./0001-turn_off_custom_alloc.patch
	];
  buildPhase = ''
  	ls
	rustc --version
	 export HOME=$(pwd)
	npm install
	ls
	CI=true npm run tauri build --verbose || echo "Skip bundle"
  '';


  installPhase = ''
    mkdir -p $out/bin
    echo Install
    ls
    ls src-tauri
    ls src-tauri/target
    ls src-tauri/target/release
    ls src-tauri/target/release/bundle
    ls src-tauri/target/release/bundle/macos
    cp -r "src-tauri/target/release/bundle/macos/Desktop Postflop.app" $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/b-inary/desktop-postflop/";
    description = "Texas Hold'em GTO solver";
    longDescription = ''
    	Advanced open-source Texas Hold'em GTO solver with optimized performance 
    '';
    license = licenses.agpl3; # wrong
    platforms = platforms.darwin;
    maintainers = with maintainers; [ maintainers.endle ];
  };
}
