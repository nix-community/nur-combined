{ lib
, stdenv
, fetchFromGitHub
, swift
, swiftpm
, swiftpm2nix
, swiftPackages
}:let
  # Pass the generated files to the helper.
  generated = swiftpm2nix.helpers ./nix;
in

stdenv.mkDerivation rec {
  pname = "xcodegen";
  version = "2.39.1";

  src = fetchFromGitHub {
    owner = "yonaskolb";
    repo = "XcodeGen";
    rev = "${version}";
    sha256 = "sha256-JH0+V3A/Qyx8kbwmyNmlcqTfNiQjXatdXPb0De29EtU=";
  };

  configurePhase = generated.configure;

  patches = [
    ./0001-patch-dependencies.patch
    ./0002-static-string.patch
  ];

  nativeBuildInputs = [ 
    swift 
    swiftpm
  ];

  buildInputs = [
    swiftPackages.XCTest
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp .build/release/xcodegen $out/bin
  '';

  meta = with lib; {
    homepage = "https://github.com/yonaskolb/XcodeGen";
    description = "A Swift command line tool for generating your Xcode project";
    longDescription = ''
      XcodeGen is a command line tool written in Swift that generates your Xcode project using your folder structure and a project spec.
    '';
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ maintainers.endle ];
  };
}
