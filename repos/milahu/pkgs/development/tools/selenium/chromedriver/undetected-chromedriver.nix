# based on
# nixpkgs/pkgs/development/tools/selenium/chromedriver/default.nix
# https://github.com/ultrafunkamsterdam/undetected-chromedriver

# note: chromedriver must have the same major version as chromium

{ lib
, stdenv
, chromedriver
}:

let
  allSpecs = {
    x86_64-linux = {
      system = "linux64";
    };

    x86_64-darwin = {
      system = "mac-x64";
    };

    aarch64-darwin = {
      system = "mac-arm64";
    };
  };

  spec = allSpecs.${stdenv.hostPlatform.system}
    or (throw "missing chromedriver binary for ${stdenv.hostPlatform.system}");
in

chromedriver.overrideAttrs (oldAttrs: rec {
  pname = "undetected-chromedriver";

  # patch this function:
  # (function () {window.cdc_adoQpoasnfa76pfcZLmcfl_Array = window.Array;...
  # ...;}).apply({navigator:
  # a: window.cdc_adoQpoasnfa76pfcZLmcfl_Array = window.Array;
  # b: return;"undetected chromedriver";_Array = window.Array;
  # the string "undetected chromedriver" is expected by undetected_chromedriver/patcher.py
  # this is valid javascript: (function() { return; ""; })()
  # based on https://github.com/ultrafunkamsterdam/undetected-chromedriver

  # note: chromedriver has no buildPhase
  # TODO assert

  buildPhase = ''
    runHook preBuild

    echo patching chromedriver
    sed -i.bak -E \
      's/\(function \(\) \{window.cdc_[a-zA-Z0-9]{22}/(function () {return;"undetected chromedriver";/' \
      "chromedriver-${spec.system}/chromedriver"
    if [[
      "$(md5sum "chromedriver-${spec.system}/chromedriver" | cut -c1-32)" == \
      "$(md5sum "chromedriver-${spec.system}/chromedriver.bak" | cut -c1-32)"
    ]]; then
      echo "error: failed to patch chromedriver"
      echo "------------ match --------------"
      grep -a -o -m1 -E '\(function \(\) \{window\.cdc_.{22}.{100}' "chromedriver-${spec.system}/chromedriver" ||
      echo "error: no match"
      echo "---------------------------------"
      exit 1
    fi
    rm "chromedriver-${spec.system}/chromedriver.bak"

    runHook postBuild
  '';
})
