{ stdenv, fetchgit, fetchurl, appimageTools, undmg, lang ? "en-US" }:
let
  inherit (stdenv.hostPlatform) system;
  throwSystem = throw "Unsupported system: ${system}";

  pname = "librewolf";
  version = if stdenv.isDarwin then "82.0" else "81.0.2";
  name = "${pname}-${version}";

  firefox = fetchurl {
    url = "https://download-installer.cdn.mozilla.net/pub/firefox/releases/${version}/mac/${lang}/Firefox%20${version}.dmg";
    sha256 = {
      en-US = "0nwd9vcjhcgjrrp433hnfl2jkbrpc9p9pll46716gln2lcpiyrav";
      eo = "04ydlxpfqns9yyh59p9j37fnm10fkdx3vy5xz40vhyad673jhg3w";
      fi = "0xzs9lcyi85p0rkx2nvhjmm03rnk491hv5r5k1shjs49aif8kzg0";
      ru = "1syiwnh6501rp0f18k91hl61ihczm23rvxy3dmcl9krpfp5148gz";
    }.${lang};
    name = "Firefox.dmg";
  };

  librewolf = fetchurl {
    url = {
      x86_64-linux = "https://gitlab.com/librewolf-community/browser/linux/uploads/7172a87315e9118745a73f45b1736931/LibreWolf-${version}-1.x86_64.AppImage";
      aarch64-linux = "https://gitlab.com/librewolf-community/browser/linux/uploads/aade76902983c173de1ddffe57daaec3/LibreWolf-${version}-1.aarch64.AppImage";
    }.${system} or throwSystem;
    sha256 = {
      x86_64-linux = "1jnnydivj673wjvyhnqvxrbj6a04cmci8hg7pdqv6978f81wyxnr";
      aarch64-linux = "134w38qk4wb4iz0gddj4ngd0q7qdyfgvrhafw29dnrzz6b8viyxi";
    }.${system} or throwSystem;
  };

  meta = with stdenv.lib; {
    description = "A fork of Firefox, focused on privacy, security and freedom";
    homepage = "https://librewolf-community.gitlab.io/";
    license = licenses.mpl20;
    maintainers = [ maintainers.sikmir ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
    skip.ci = true;
  };

  appimageContents = appimageTools.extract {
    inherit name;
    src = librewolf;
  };

  linux = appimageTools.wrapType2 rec {
    inherit name meta;
    src = librewolf;

    extraInstallCommands = ''
      mv $out/bin/{${name},${pname}}
      install -Dm644 ${appimageContents}/io.gitlab.LibreWolf.desktop -t $out/share/applications
      install -Dm644 ${appimageContents}/librewolf.png -t $out/share/icons/hicolor/256x256/apps
    '';
  };

  darwin = stdenv.mkDerivation {
    inherit pname version meta;

    src = fetchgit {
      url = "https://gitlab.com/librewolf-community/browser/macos";
      rev = "3fcf44663ff1fb4e180fb3cdb26620abe7284b53";
      sha256 = "0p517ixkgp3sl7b26mdjr9mwv6155xx8ah85fgpwqnpryr64xs3d";
    };

    postPatch = ''
      substituteInPlace package.sh \
        --replace "codesign" "/usr/bin/codesign" \
        --replace "cp" "/bin/cp" \
        --replace "hdiutil" "/usr/bin/hdiutil" \
        --replace "out_dir=" "out_dir=. #"
    '';

    buildPhase = ''
      # Use fresh FF dmgs for each build.
      cp ${firefox} Firefox.dmg
      ./package.sh Firefox.dmg
    '';

    installPhase = ''
      ${undmg}/bin/undmg LibreWolf.dmg
      mkdir -p $out/Applications
      cp -R LibreWolf.app $out/Applications
    '';
  };
in
if stdenv.isDarwin
then darwin
else linux
