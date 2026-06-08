fetchurl: {
  boa-utils = {
    es-toolkit = fetchurl {
      url = "https://fastly.jsdelivr.net/npm/es-toolkit@1.39.10/+esm";
      hash = "sha256-Qj46nmTVJ0xVSOMfd4DYWsp2qQYCMW8SKRGYP1vZa+M=";
    };

    yaml = fetchurl {
      url = "https://fastly.jsdelivr.net/npm/yaml@2.8.1/+esm";
      hash = "sha256-MQW9Az7z7AKq5uw1C5zYqwyV95mxSS2R+87Wnng1eN8=";
    };

    dedent = fetchurl {
      url = "https://fastly.jsdelivr.net/npm/dedent@1.7.0/+esm";
      hash = "sha256-nzWmx62HFdyr+97z3OAEyr/GnCEiUUv+20npLYBsX4E=";
    };

    js-base64 = fetchurl {
      url = "https://fastly.jsdelivr.net/npm/js-base64@3.7.8/+esm";
      hash = "sha256-r6YyhW+PkZbV6OAPQGyBncRWR1qZhBvXSJN8BHbJJhU=";
    };
  };
}
