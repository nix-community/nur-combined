{ fetchurl, bundler, ruby }:

bundler.overrideAttrs (old: {
  inherit ruby;
  name = "bundler-2.3.24";
  src = fetchurl {
    url = "https://rubygems.org/gems/bundler-2.3.24.gem";
    hash = "sha256-6qLrjDiS6HD5eSUrIZa9d+tVHh2/PNxOsWS6AexEOMQ=";
  };
})
