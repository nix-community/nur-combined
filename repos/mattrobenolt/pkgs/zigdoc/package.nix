{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchurl,
  runCommandLocal,
  zig_0_16,
}:

let
  versionData = builtins.fromJSON (builtins.readFile ./hashes.json);
  inherit (versionData) version;

  # build.zig imports the ziglint dependency while configuring, even for the
  # default install step, so Zig tries to download it and fails in the
  # sandbox. Unpack it ahead of time into the layout `zig build --system`
  # expects. Keep this version in sync with build.zig.zon in the source.
  ziglintSource = fetchurl {
    url = "https://github.com/baskingspot/ziglint/archive/refs/tags/v0.5.3.tar.gz";
    hash = "sha256-XgWOQdvyxysodofCKikw6o94GAdRL53fc5X7Jzag61w=";
  };

  zigDeps = runCommandLocal "zigdoc-${version}-zig-deps" { nativeBuildInputs = [ zig_0_16 ]; } ''
    mkdir work
    cd work
    touch build.zig
    cp ${ziglintSource} ziglint.tar.gz
    zig fetch --global-cache-dir "$TMPDIR/cache" ./ziglint.tar.gz >/dev/null

    mkdir -p $out
    mv zig-pkg/* $out/
  '';
in
stdenvNoCC.mkDerivation {
  pname = "zigdoc";
  inherit version;

  src = fetchFromGitHub {
    owner = "baskingspot";
    repo = "zigdoc";
    rev = "v${version}";
    hash = versionData.sourceHash;
  };

  nativeBuildInputs = [ zig_0_16 ];
  zigBuildFlags = [
    "--system"
    "${zigDeps}"
  ];

  meta = with lib; {
    description = "Generate documentation from Zig source code";
    homepage = "https://github.com/baskingspot/zigdoc";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "zigdoc";
    platforms = platforms.all;
  };
}
