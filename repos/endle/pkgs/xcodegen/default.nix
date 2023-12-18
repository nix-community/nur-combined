{ lib
, stdenv
, fetchFromGitHub
, swift
, swiftpm
, swiftPackages
, darwin
, xcbuild
, cacert # Required by git during build process
}:

stdenv.mkDerivation rec {
  pname = "xcodegen";
  version = "2.38.0";

  src = fetchFromGitHub {
    owner = "yonaskolb";
    repo = "XcodeGen";
    rev = "${version}";
    sha256 = "sha256-5N0ZNQec1DUV4rWqqOC1Aikn+RKrG8it0Ee05HG2mn4=";
  };

  patches = [
    ./0001-Fix-git-URL-scheme.patch
    ./0002-Bump-Spectre-Version.patch # Workaround build failures caused by XCTest.swift in Spectre
    ./0003-static-string.patch
  ];


  nativeBuildInputs = [
    darwin.apple_sdk.frameworks.Foundation
  ];

  buildInputs = [
    swift
    swiftpm
    darwin.apple_sdk.frameworks.Foundation
    swiftPackages.XCTest
    swiftPackages.Foundation
    xcbuild # for xcrun
    cacert
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp .build/release/xcodegen $out/bin
  '';

  enableParallelBuilding = true;


  meta = with lib; {
    homepage = "https://github.com/yonaskolb/XcodeGen";
    description = "A Swift command line tool for generating your Xcode project";
    longDescription = ''
      XcodeGen is a command line tool written in Swift that generates your Xcode project using your folder structure and a project spec.
    '';
    license = licenses.mit;
    platforms = platforms.darwin;
    maintainers = with maintainers; [ endle ];
  };
}
