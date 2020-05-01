{ buildGoModule, fetchFromGitHub, lib}:
buildGoModule rec {
  name = "efm-langserver";
  version = "0.0.14";
  src = fetchFromGitHub {
    owner = "mattn";
    repo = "efm-langserver";
    rev = "v${version}";
    sha256 = "0gswjz9m68xl8r9f11bqp71lvb0b8j0j7vy0nkiwf4rmsyg0mjnb";
  };
  modSha256 = "0mi0rhfxbb06jjc87jl07kg9dgjysracc0ndjwmz9vic5jrjvydz";
  subPackages = ["."];

  meta = with lib; {
    description = "General purpose Language Server";
    homepage = https://github.com/mattn/efm-langserver;
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
  };
}

