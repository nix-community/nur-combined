{ buildGoModule
, fetchFromGitHub
, gitUpdater
, lib
}:

buildGoModule rec {
  pname = "blocky-ui";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "ivvija";
    repo = "blocky-ui";
    rev = "refs/tags/v${version}";
    hash = "sha256-+owS2CVcKPSTscEoXBXZjLDqGlJH+lg6GOfZ4PfOg5M=";
  };

  postPatch = ''
    substituteInPlace 'main.go' \
      --replace-fail 'Dir("assets")' 'Dir("'"$out"'/lib/assets")'
  '';

  vendorHash = "sha256-3xyV1TaKK7tiKz6crKikTF4Hf7m1IOyBRJt36i2a4mU=";

  postInstall = ''
    mkdir --parents $out/lib
    cp --recursive assets $out/lib/assets
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Simple web interface for Blocky";
    homepage = "https://github.com/ivvija/blocky-ui";
    license = lib.licenses.unfree; # No license;
    mainProgram = "blocky-ui";
  };
}
