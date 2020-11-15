{ stdenv, lib, fetchFromGitHub, buildGoModule }:
with stdenv.lib;

buildGoModule {
  name = "duckling-proxy";

  src = fetchFromGitHub {
    owner = "LukeEmmet";
    repo = "duckling-proxy";
    rev = "cdb5f327b780d058b2da72026143ad6755afece5";
    sha256 = "1r8wmwydx8asi8ixyrbw9139vs9bjkfn4ry0jfwr54dls6xjn2s4";
  };

  vendorSha256 = "0wxk1a5gn9a7q2kgq11a783rl5cziipzhndgp71i365y3p1ssqyf";

  meta = {
    description = "Duckling proxy is a Gemini proxy to access the Small Web";
    homepage = "https://github.com/LukeEmmet/duckling-proxy";
    license = "MIT";
    platforms = platforms.linux;
  };
}
