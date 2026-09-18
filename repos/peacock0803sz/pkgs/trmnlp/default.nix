{ lib, bundlerApp, ruby_4_0, makeWrapper, imagemagick }:
# https://github.com/usetrmnl/trmnlp
#
# Packaged from the published `trmnl_preview` gem rather than the git tree.
# To bump: edit the version in ./Gemfile, then regenerate the lockfile and the
# gemset inside this directory:
#
#     nix shell nixpkgs#ruby_4_0 nixpkgs#bundix
#     bundle lock --add-platform ruby
#     bundix
bundlerApp {
  # `pname` must name a gem in gemset.nix; the version is read from there.
  pname = "trmnl_preview";
  gemdir = ./.;
  exes = [ "trmnlp" ];

  # The gemspec requires Ruby >= 4.0.
  ruby = ruby_4_0;

  nativeBuildInputs = [ makeWrapper ];

  # nixpkgs' gem-config only puts graphicsmagick on mini_magick's PATH, but the
  # PNG quantizer shells out to ImageMagick 7's `magick`. Suffix rather than
  # prefix so a user-provided magick still wins. Firefox (needed by
  # selenium-webdriver for `--png` rendering) is deliberately left to the
  # ambient environment: it is unavailable on darwin and huge on linux.
  postBuild = ''
    wrapProgram $out/bin/trmnlp \
      --suffix PATH : ${lib.makeBinPath [ imagemagick ]}
  '';

  meta = {
    description = "Local web server to preview TRMNL plugins";
    homepage = "https://github.com/usetrmnl/trmnlp";
    license = lib.licenses.mit;
    mainProgram = "trmnlp";
  };
}
