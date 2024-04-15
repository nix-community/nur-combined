{ stdenv
, lib
, fetchFromGitHub
, gitUpdater
, zip
}:
stdenv.mkDerivation rec {
  pname = "i-still-dont-care-about-cookies";
  version = "1.1.4";
  src = fetchFromGitHub {
    owner = "OhMyGuus";
    repo = "I-Still-Dont-Care-About-Cookies";
    rev = "v${version}";
    hash = "sha256-bs9Looh2fKmsT0/3rS5Ldta4wlOUc75DpGxwBc7yRmg=";
  };

  nativeBuildInputs = [ zip ];

  postPatch = ''
    # firefox claims to support manifest v3, but actually it won't load unless i point it to v2.
    ln -s manifest_v2.json src/manifest.json
  '';

  installPhase = ''
    pushd src
    zip -r $out ./*
    popd
  '';

  passthru = {
    extid = "idcac-pub@guus.ninja";
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    homepage = "https://github.com/OhMyGuus/I-Still-Dont-Care-About-Cookies";
    description = ''Debloated fork of the extension "I don't care about cookies"'';
    maintainer = with lib.maintainers; [ colinsane ];
  };
}
