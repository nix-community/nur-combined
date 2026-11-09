# TODO make this more based on
# https://github.com/daijro/camoufox/blob/main/.github/workflows/release.yml
# also install "uBlock Origin" (ubo)

# this takes 4 hours to build on my CPU: AMD Ryzen 5 5600H (6C/12T, 3.30-4.20GHz)

# FIXME?
/*
$ camoufox
JavaScript warning: resource://services-settings/Utils.sys.mjs, line 125: unreachable code after return statement
console.error: Policies: 
  Add-on ID (webcompat@mozilla.org) couldn't be uninstalled: Cannot uninstall addon webcompat@mozilla.org from locked install location app-builtin-addons
console.error: Policies: 
  Add-on ID (pictureinpicture@mozilla.org) couldn't be uninstalled: Cannot uninstall addon pictureinpicture@mozilla.org from locked install location app-builtin-addons
console.error: Policies: 
  Add-on ID (formautofill@mozilla.org) couldn't be uninstalled: Cannot uninstall addon formautofill@mozilla.org from locked install location app-builtin-addons
JavaScript error: moz-src:///toolkit/components/search/SearchUtils.sys.mjs, line 143: Error: An engine called None already exists!
JavaScript error: resource://gre/modules/juggler/Helper.js, line 95: NS_ERROR_FAILURE: Component returned failure code: 0x80004005 (NS_ERROR_FAILURE) [nsIWebProgress.removeProgressListener]
JavaScript error: resource://gre/modules/juggler/SimpleChannel.js, line 1: SyntaxError: redeclaration of let SimpleChannel
JavaScript error: resource://gre/modules/juggler/SimpleChannel.js, line 1: SyntaxError: redeclaration of let SimpleChannel
JavaScript error: resource://gre/modules/juggler/SimpleChannel.js, line 1: SyntaxError: redeclaration of let SimpleChannel
JavaScript error: resource://gre/modules/juggler/Helper.js, line 95: NS_ERROR_FAILURE: Component returned failure code: 0x80004005 (NS_ERROR_FAILURE) [nsIWebProgress.removeProgressListener]
JavaScript error: resource://gre/modules/juggler/SimpleChannel.js, line 1: SyntaxError: redeclaration of let SimpleChannel
JavaScript error: resource://gre/modules/juggler/SimpleChannel.js, line 1: SyntaxError: redeclaration of let SimpleChannel
JavaScript error: resource://gre/modules/juggler/SimpleChannel.js, line 1: SyntaxError: redeclaration of let SimpleChannel
JavaScript error: resource://gre/modules/juggler/Helper.js, line 95: NS_ERROR_FAILURE: Component returned failure code: 0x80004005 (NS_ERROR_FAILURE) [nsIWebProgress.removeProgressListener]
JavaScript error: resource://nimbus/lib/SharedDataMap.sys.mjs, line 247: Error: SharedDataMap: in shutdown
*/

{
  lib,
  stdenv,
  buildMozillaMach,
  callPackage,
  fetchurl,
  fetchFromGitHub,
  python3,
  unzip,
  coreutils,
  gnused,
  gnugrep,
  findutils,
  gnutar,
  xz,
  zstd,
  fontconfig,

  # TODO remove debug code
  ripgrep, # debug
}:

let
  src = callPackage ./src.nix { };
in

(
(
(
buildMozillaMach {
  pname = "camoufox";

  # TODO restore full version
  # version = src.version;
  version = src.firefoxVersion;

  applicationName = "Camoufox";
  binaryName = "camoufox";

  # src = patches;
  src = src.firefoxSource;

  branding = "browser/branding/camoufox";

  # no: error: function 'anonymous lambda' called with unexpected argument 'withFFmpeg'
  # fix? mozbuild.configure.options.InvalidOptionError: Unknown option: --enable-ffmpeg(B(B
  # withFFmpeg = false;

  # TODO remove debug code
  # TODO remove "if false; then ..."
  # postUnpack = ''
  unpackPhase = ''
    sourceRoot=source

    mkdir -v $sourceRoot

    pushd $sourceRoot

    echo "extracting firefox source from $src"
    tar -x --strip-components=1 -f $src

    echo "applying camoufox patches from ${src.camoufoxSource}"

    # Match upstream copy-additions.sh.
    mkdir -p lw
    cp ${src.camoufoxSource}/browser/settings/camoufox.cfg lw/
    cp ${src.camoufoxSource}/browser/settings/distribution/policies.json lw/
    cp ${src.camoufoxSource}/browser/settings/defaults/pref/local-settings.js lw/
    cp ${src.camoufoxSource}/browser/settings/properties.json lw/
    touch lw/moz.build

    cp -r ${src.camoufoxSource}/browser/additions/. .

    printf '%s\n' \
      "${src.version}" \
      > browser/config/version.txt
    printf '%s\n' \
      "${src.version}" \
      > browser/config/version_display.txt

    if false; then
      # Apply every patch recursively in upstream basename order.
      # Sorting by basename, rather than full relative path, matches
      # Camoufox's scripts/_mixin.py list_patches().
      mapfile -t patch_files < <(
        find ${src.camoufoxSource}/browser/patches \
          -type f -name '*.patch' -printf '%f\t%p\n' \
          | sort -k1,1 -k2,2 \
          | cut -f2-
      )

      for patch_file in "''${patch_files[@]}"; do
        echo "Applying Camoufox patch: $patch_file"
        patch -p1 --forward -l --batch --input="$patch_file"
      done
    fi

    # Apply every patch recursively in upstream basename order.
    # Sorting by basename, rather than full relative path, matches
    # Camoufox's scripts/_mixin.py list_patches().
    find ${src.camoufoxSource}/browser/patches -type f -name '*.patch' -printf '%f\t%p\n' |
      sort -k1,1 -k2,2 |
      cut -f2- |
      while read patch_file; do
        echo "Applying Camoufox patch: $patch_file"
        patch -p1 --forward -l --batch --input="$patch_file"
      done

    popd

    if false; then
      set -x
      pwd
      ls
      ${ripgrep}/bin/rg -F -- --enable-ffmpeg || true
      set +x
      # exit 1
    fi

    export TERM=dumb # disable ANSI colors
  '';

  extraConfigureFlags = [
    "--with-app-name=camoufox"
    "--with-branding=browser/branding/camoufox"
    "--allow-addon-sideload"
    "--disable-crashreporter"
    "--disable-backgroundtasks"
    "--disable-default-browser-agent"
    "--disable-tests"
    "--disable-updater"
    "--disable-system-policies"
    "--with-unsigned-addon-scopes=app,system"
  ];

  # FIXME buildMozillaMach should not add "--enable-ffmpeg"
  # FIXME build nss in a separate derivation
  # TODO remove debug code
  # TODO restore full MOZ_PKG_VERSION. this was a try to fix the "--enable-ffmpeg" problem
  extraPreConfigure = ''
    export MOZ_TELEMETRY_REPORTING=
    # export MOZ_PKG_VERSION=${src.version}
    export MOZ_PKG_VERSION=${src.firefoxVersion}
    export MOZILLA_OFFICIAL=1

    configureFlags2=()
    for x in "''${configureFlags[@]}"; do
      case "$x" in
        --enable-ffmpeg)
          # remove flag
          # fix: Unknown option: --enable-ffmpeg
          :
        ;;
        --with-system-nss)
          # remove flag
          # fix: ERROR: Requested 'nss >= 3.130' but version of NSS is 3.128.0
          :
        ;;
        *)
          configureFlags2+=("$x")
        ;;
      esac
    done
    configureFlags=("''${configureFlags2[@]}")
    unset configureFlags2

    set -x
    echo "running configure ..."
  '';

  extraPostPatch = ''
    # Ensure Nix's build remains offline and fails if any source
    # preparation step has left unresolved patch artifacts.
    if find . -type f \( -name '*.rej' -o -name '*.orig' \) \
      | grep -q .; then
      echo "Unresolved patch artifacts found" >&2
      exit 1
    fi
  '';

  # FIXME buildMozillaMach should pass unexpected arguments to stdenv.mkDerivation
  # error: function 'anonymous lambda' called with unexpected argument 'passthru'
  /*
  passthru = {
    inherit (src) firefoxVersion camoufoxVersion;
  };
  */

  meta = {
    description = "Camoufox privacy and automation browser built from source";
    homepage = "https://github.com/daijro/camoufox";
    license = lib.licenses.mpl20;
    # TODO all platforms?
    platforms = [ "x86_64-linux" ];
    mainProgram = "camoufox";
  };
}
# TODO why override
).override {
  enableAddonSigning = false;
  enableAddonSideload = true;
  enableCrashReporter = false;
  enableOfficialBranding = true;
}
)
).overrideAttrs (oldAttrs: {
  passthru = {
    inherit (src) firefoxVersion camoufoxVersion;
  };
})
