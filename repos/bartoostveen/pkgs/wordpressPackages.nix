{
  lib,
  newScope,
}:

let
  inherit (lib)
    makeScope
    substring
    recurseIntoAttrs
    ;
in
makeScope newScope (self: recurseIntoAttrs {
  mkWpPlugin =
    {
      stdenv,
      fetchzip,
      pname,
      id,
      version,
      hash,
      url ? "https://downloads.wordpress.org/plugin/${id}.${version}.zip",
    }:

    stdenv.mkDerivation {
      inherit pname version;
      src = fetchzip {
        inherit url hash;
      };
      installPhase = "mkdir -p $out; cp -R * $out/";
    };

  plugins = {
    antispam-bee = self.callPackage self.mkWpPlugin {
      pname = "antispam-bee";
      version = "2.11.12";
      id = "antispam-bee";
      hash = "sha256-PsymEQIKhMNRS+Q/A/54G3vPlBwudlOVULKpH4q0fXg=";
    };
    contact-form-7 = self.callPackage self.mkWpPlugin {
      pname = "wp-contact-form-7";
      version = "6.1.6";
      id = "contact-form-7";
      hash = "sha256-5s5y2+NveHIrLVhZmS9sPvYnCxFd+/ggbqq2nyusg3E=";
    };
    indexnow = self.callPackage self.mkWpPlugin {
      pname = "indexnow";
      version = "1.0.4";
      id = "indexnow";
      url = "https://downloads.wordpress.org/plugin/indexnow.zip";
      hash = "sha256-YLzRJ7gXl03nUcEuYa3+jn5QdapDeyxZZHtYxgIoHOA=";
    };
    generic-oidc = self.callPackage self.mkWpPlugin {
      pname = "wp-generic-oidc";
      version = "3.11.3";
      id = "daggerhart-openid-connect-generic";
      hash = "sha256-/mqGWQz1lHsnA2dpQEZQVCWmqFSmDslFd4rzeEC4PA8=";
    };
    gutenberg = self.callPackage ../pkgs/gutenberg/package.nix { };
    gutenberg-carousel = self.callPackage self.mkWpPlugin {
      pname = "wp-gutenberg-carousel";
      version = "2.1.5";
      id = "carousel-block";
      hash = "sha256-uy9f1RgpI92bEKCvmmQxecBzkhvrJUvzD21TrlhzqoE=";
    };
    modify-profile-fields = self.callPackage self.mkWpPlugin {
      pname = "wp-modify-profile-fields";
      version = "1.2.0";
      id = "user-profile-dashboard-fields-control";
      hash = "sha256-hsUXAah7EFRKwB6Z/HzkBLCVH0kZl3oohHUXN1mWn2g=";
    };
    view-transitions = self.callPackage self.mkWpPlugin {
      pname = "wp-view-transitions";
      version = "1.2.1";
      id = "view-transitions";
      hash = "sha256-RNcdPFfRuRHljuh2IhR+L/NuayreNBeLAvuAEqLMrFA=";
    };
  };

  mkLanguage =
    {
      stdenv,
      fetchzip,
      language,
      languageShort ? substring 0 2 language,
      wordpress,
      hash,
    }:

    stdenv.mkDerivation (finalAttrs: {
      name = "wp-language-${languageShort}";
      inherit (wordpress) version;
      inherit language languageShort;

      src = fetchzip {
        url = "https://${languageShort}.wordpress.org/wordpress-${finalAttrs.version}-${finalAttrs.language}.zip";
        name = "wp-${finalAttrs.version}-language-${finalAttrs.languageShort}";
        inherit hash;
      };

      installPhase = "mkdir -p $out; cp -r ./wp-content/languages/* $out/";
    });

  languages = {
    nl = self.callPackage self.mkLanguage {
      language = "nl_NL";
      hash = "sha256-CipLLCxHSMhMjFYMCTUAZbGA3iAWWfzM13DXzR17wB8=";
    };
  };
})
