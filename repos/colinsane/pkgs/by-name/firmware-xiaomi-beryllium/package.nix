{
  fetchFromGitLab,
  stdenv,
  unstableGitUpdater,
}:
stdenv.mkDerivation {
  name = "firmware-xiaomi-beryllium";
  version = "0-unstable-2026-04-28";

  src = fetchFromGitLab {
    owner = "sdm845-mainline";
    repo = "firmware-xiaomi-beryllium";
    rev = "d396d32118803235a58aab0d0bc3643256634a05";
    hash = "sha256-KKV6/2DJrz+keUVxKR3M6CQcCYQ518xMyxUqgIyAu/s=";
  };

  dontBuild = true;

  # there's a /lib and a /usr directory. i've never seen the latter in a firmware package, but maybe it's needed
  installPhase = ''
    mkdir -p $out
    cp -R lib $out
  '';

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Linux firmware files associated with Xiaomi Pocophone";
    homepage = "https://gitlab.com/sdm845-mainline/firmware-xiaomi-beryllium";
  };
}
