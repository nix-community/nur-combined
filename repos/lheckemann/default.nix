{ pkgs ? import <nixpkgs> {} }: {
  asql = pkgs.callPackage ./asql.nix {};
  x11 = pkgs.recurseIntoAttrs (pkgs.callPackages ./x11 {});
  pb_cli = pkgs.runCommand "pb" {} ''
    install -Dm 555 ${pkgs.fetchurl {
      url = https://raw.githubusercontent.com/ptpb/pb_cli/5242382b3d6b5c0ddaf6e4843a69746b40866e57/src/pb.sh;
      sha256 = "146cfsy3mxlzkx8m20fqzrswvgkj2vfgfqrjd0kl6lca33iw758m";
    }} $out/bin/pb
    runHook fixupPhase
  '';

  manaplus = with pkgs; stdenv.mkDerivation rec {
    name = "${pname}-${version}";
    pname = "manaplus";
    version = "1.8.9.1";
    nativeBuildInputs = [autoreconfHook pkgconfig];
    buildInputs = [SDL SDL_mixer SDL_image SDL_net SDL_ttf SDL_gfx libxml2 zlib curl libGL libpng];
    src = fetchFromGitLab {
      owner = pname;
      repo = pname;
      rev = "v${version}";
      sha256 = "1ni4qhhcyaixf5nhlwh0q5khsl76wpc4c0yflmvxlmf28wyy60lg";
    };
  };
}
