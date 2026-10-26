{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation {
  pname = "helix-oil";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Ra77a3l3-jar";
    repo = "oil.hx";
    rev = "5293af9033bc7de95334f9d5a399c149a7eadd75";
    hash = "sha256-pSfB9Gexqz+OaXYniN7JEtjb6LIo5GcM3reuCmXl93k=";
  };

  notifySrc = fetchFromGitHub {
    owner = "chuwy";
    repo = "notify.hx";
    rev = "0a328073e6d3e5041346374ae747c275ab8ce746";
    hash = "sha256-shKUVnJw2j0yYO+mTHsKie+d1VrJGWDTRul+PTpqlhs=";
  };

  dontBuild = true;

  postPatch = ''
    cp "$notifySrc/notify.scm" notify.scm
    chmod u+w notify.scm
    substituteInPlace notify.scm \
      --replace-fail '(if area (position (+ 3 (area-y area)) (+ 2 (area-x area))))))' \
      '(if area (position (+ 3 (area-y area)) (+ 2 (area-x area))) #f)))'
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 oil.scm $out/share/steel/cogs/oil/oil.scm
    install -Dm644 cog.scm $out/share/steel/cogs/oil/cog.scm
    install -Dm644 notify.scm $out/share/steel/cogs/notify/notify.scm
    install -Dm644 "$notifySrc/cog.scm" $out/share/steel/cogs/notify/cog.scm

    runHook postInstall
  '';

  meta = {
    description = "Editable file manager for Helix Steel";
    homepage = "https://github.com/Ra77a3l3-jar/oil.hx";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
