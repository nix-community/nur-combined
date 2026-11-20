fetchurl: {
  boa-utils = {
    es-toolkit = fetchurl {
      url = "https://fastly.jsdelivr.net/npm/es-toolkit@1.39.10/+esm";
      hash = "sha256-M6ZXYKpCbN+5Q5pbxJVnvy7M7FFEnt0g0zd5T8Xilts=";
    };

    yaml = fetchurl {
      url = "https://fastly.jsdelivr.net/npm/yaml@2.8.1/+esm";
      hash = "sha256-wQ/cVzdEcsyTn/Y7EWp7OVG9gcnch6FBQZCgPek9eos=";
    };

    dedent = fetchurl {
      url = "https://fastly.jsdelivr.net/npm/dedent@1.7.0/+esm";
      hash = "sha256-RT7onzRx0WrmsLmu4jgtDPhcnLsV/U8VbDO8P45yZgI=";
    };

    js-base64 = fetchurl {
      url = "https://fastly.jsdelivr.net/npm/js-base64@3.7.8/+esm";
      hash = "sha256-3jLRvoyvK1Mgt/h6EuAXX60wuAe/GvafEl0oGxnuDEs=";
    };
  };
}
