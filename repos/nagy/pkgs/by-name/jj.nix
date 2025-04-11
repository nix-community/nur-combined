{
  lib,
  stdenv,
  fetchFromGitHub,
  gawk,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jj";
  version = "0.9";

  src = fetchFromGitHub {
    owner = "aaronNGi";
    repo = "jj";
    rev = "v${finalAttrs.version}";
    hash = "sha256-6MQY2amBa9NZKLwl5XdwWK3/mw5gkpv8hdykA9UQrgg=";
  };

  makeFlags = [
    "PREFIX=$(out)"
    "CC:=$(CC)"
  ];

  buildInputs = [ gawk ]; # to patch shebangs

  meta = {
    description = "An evolution of the suckless ii(1) file-based IRC client";
    license = lib.licenses.mit;
    homepage = "https://github.com/aaronNGi/jj";
    mainProgram = "jjd";
  };
})
