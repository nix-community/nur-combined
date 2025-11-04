{
  buildGoModule,
  lib,
  fetchFromGitHub,
}:
let
  version = "1.1.5";
  pname = "trzsz-go";

  src = fetchFromGitHub {
    owner = "trzsz";
    repo = "${pname}";
    # fetching the main branch by default; change to a tag for stable builds
    rev = "v${version}";
    # placeholder; replace with the real sha256 after doing a build
    sha256 = "sha256-Uivb8tGiQ+5RUrx1pVefZSl8EKybGLqZR+DhZp+8B7M=";
  };

in
buildGoModule rec {
  inherit pname version src;

  # include version in name to make it clear this is an unstable build
  name = "${pname}-${version}";
  # vendorHash can be left as a placeholder for now
  vendorHash = "sha256-kZu0q/E3NWcYGRBQNoScBm3dXLcmVNtgrZFrhvA2wps=";

  meta = {
    description = "trzsz is a simple file transfer tool, similar to lrzsz (rz/sz), and compatible with tmux.";
    homepage = "https://github.com/trzsz/trzsz";
    license = lib.licenses.mit;
    maintainers = [ "KongJian520" ];
    platforms = [ "x86_64-linux" ];
    # this package provides two CLI programs: trz and tsz
    mainProgram = "trz and tsz";
  };
}
