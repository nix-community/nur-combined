{ stdenv,
  fetchgit,
  rustPlatform,
  cmake,
  makeWrapper,
  expat,
  pkgconfig,
  freetype,
  fontconfig,
  libX11,
  gperf,
  libXcursor,
  libXxf86vm,
  libXi,
  libXrandr,
  xclip,
  darwin}:

with rustPlatform;

let
  rpathLibs = [
    expat
    freetype
    fontconfig
    libX11
    libXcursor
    libXxf86vm
    libXrandr
    libXi
  ];
in buildRustPackage rec {
  name = "alacritty-unstable-${version}";
  version = "2018-03-04";

  # At the moment we cannot handle git dependencies in buildRustPackage.
  # This fork only replaces rust-fontconfig/libfontconfig with a git submodules.
  src = fetchgit {
    url = https://github.com/Mic92/alacritty.git;
    rev = "rev-${version}";
    sha256 = "0pxnc6r75c7rwnsqc0idi4a60arpgchl1i8yppibhv0px5w11mwa";
    fetchSubmodules = true;
  };

  cargoSha256 = "0q2yy9cldng8znkmhysgrwi43z2x7a8nb1bnxpy9z170q8ds0m0j";

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkgconfig
  ] ++ stdenv.lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
       AppKit
       Carbon
       CoreGraphics
       CoreText
  ]);

  buildInputs = rpathLibs;

  postPatch = stdenv.lib.optional stdenv.isLinux ''
    substituteInPlace copypasta/src/x11.rs \
      --replace Command::new\(\"xclip\"\) Command::new\(\"${xclip}/bin/xclip\"\)
  '';

  installPhase = if stdenv.isDarwin then ''
    runHook preInstall
    mkdir -p "$out/Applications/Alacritty.app/Contents/MacOS"
	  cp -fRp $src/assets/osx/Alacritty.app/* $out/Applications/Alacritty.app/
	  cp -fp target/release/alacritty $out/Applications/Alacritty.app/Contents/MacOS
    runHook postInstall
    '' else  ''
    runHook preInstall

    install -D target/release/alacritty $out/bin/alacritty
    patchelf --set-rpath "${stdenv.lib.makeLibraryPath rpathLibs}" $out/bin/alacritty

    install -D Alacritty.desktop $out/share/applications/alacritty.desktop

    runHook postInstall
  '';

  dontPatchELF = true;

  meta = with stdenv.lib; {
    description = "GPU-accelerated terminal emulator";
    homepage = https://github.com/jwilm/alacritty;
    license = with licenses; [ asl20 ];
    maintainers = with maintainers; [ mic92 ];
    platforms = platforms.linux ++ platforms.darwin;
  };
}
