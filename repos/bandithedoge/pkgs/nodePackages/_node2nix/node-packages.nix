# This file has been generated by node2nix 1.11.1. Do not edit!
{
  nodeEnv,
  fetchurl,
  fetchgit,
  nix-gitignore,
  stdenv,
  lib,
  globalBuildInputs ? [],
}: let
  sources = {
    "@babel/helper-string-parser-7.25.9" = {
      name = "_at_babel_slash_helper-string-parser";
      packageName = "@babel/helper-string-parser";
      version = "7.25.9";
      src = fetchurl {
        url = "https://registry.npmjs.org/@babel/helper-string-parser/-/helper-string-parser-7.25.9.tgz";
        sha512 = "4A/SCr/2KLd5jrtOMFzaKjVtAei3+2r/NChoBNoZ3EyP/+GlhoaEGoWOZUmFmoITP7zOJyHIMm+DYRd8o3PvHA==";
      };
    };
    "@babel/helper-validator-identifier-7.25.9" = {
      name = "_at_babel_slash_helper-validator-identifier";
      packageName = "@babel/helper-validator-identifier";
      version = "7.25.9";
      src = fetchurl {
        url = "https://registry.npmjs.org/@babel/helper-validator-identifier/-/helper-validator-identifier-7.25.9.tgz";
        sha512 = "Ed61U6XJc3CVRfkERJWDz4dJwKe7iLmmJsbOGu9wSloNSFttHV0I8g6UAgb7qnK5ly5bGLPd4oXZlxCdANBOWQ==";
      };
    };
    "@babel/parser-7.26.5" = {
      name = "_at_babel_slash_parser";
      packageName = "@babel/parser";
      version = "7.26.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/@babel/parser/-/parser-7.26.5.tgz";
        sha512 = "SRJ4jYmXRqV1/Xc+TIVG84WjHBXKlxO9sHQnA2Pf12QQEAp1LOh6kDzNHXcUnbH1QI0FDoPPVOt+vyUDucxpaw==";
      };
    };
    "@babel/types-7.26.5" = {
      name = "_at_babel_slash_types";
      packageName = "@babel/types";
      version = "7.26.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/@babel/types/-/types-7.26.5.tgz";
        sha512 = "L6mZmwFDK6Cjh1nRCLXpa6no13ZIioJDz7mdkzHv399pThrTa/k0nUlNaenOeh2kWu/iaOQYElEpKPUswUa9Vg==";
      };
    };
    "@emmetio/abbreviation-2.3.3" = {
      name = "_at_emmetio_slash_abbreviation";
      packageName = "@emmetio/abbreviation";
      version = "2.3.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/@emmetio/abbreviation/-/abbreviation-2.3.3.tgz";
        sha512 = "mgv58UrU3rh4YgbE/TzgLQwJ3pFsHHhCLqY20aJq+9comytTXUDNGG/SMtSeMJdkpxgXSXunBGLD8Boka3JyVA==";
      };
    };
    "@emmetio/css-abbreviation-2.1.8" = {
      name = "_at_emmetio_slash_css-abbreviation";
      packageName = "@emmetio/css-abbreviation";
      version = "2.1.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/@emmetio/css-abbreviation/-/css-abbreviation-2.1.8.tgz";
        sha512 = "s9yjhJ6saOO/uk1V74eifykk2CBYi01STTK3WlXWGOepyKa23ymJ053+DNQjpFcy1ingpaO7AxCcwLvHFY9tuw==";
      };
    };
    "@emmetio/scanner-1.0.4" = {
      name = "_at_emmetio_slash_scanner";
      packageName = "@emmetio/scanner";
      version = "1.0.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/@emmetio/scanner/-/scanner-1.0.4.tgz";
        sha512 = "IqRuJtQff7YHHBk4G8YZ45uB9BaAGcwQeVzgj/zj8/UdOhtQpEIupUhSk8dys6spFIWVZVeK20CzGEnqR5SbqA==";
      };
    };
    "@types/node-17.0.45" = {
      name = "_at_types_slash_node";
      packageName = "@types/node";
      version = "17.0.45";
      src = fetchurl {
        url = "https://registry.npmjs.org/@types/node/-/node-17.0.45.tgz";
        sha512 = "w+tIMs3rq2afQdsPJlODhoUEKzFP1ayaoyl1CcnwtIlsVe7K7bA1NGm4s3PraqTLlXnbIN84zuBlxBWo1u9BLw==";
      };
    };
    "@vscode/emmet-helper-2.11.0" = {
      name = "_at_vscode_slash_emmet-helper";
      packageName = "@vscode/emmet-helper";
      version = "2.11.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/@vscode/emmet-helper/-/emmet-helper-2.11.0.tgz";
        sha512 = "QLxjQR3imPZPQltfbWRnHU6JecWTF1QSWhx3GAKQpslx7y3Dp6sIIXhKjiUJ/BR9FX8PVthjr9PD6pNwOJfAzw==";
      };
    };
    "acorn-8.14.0" = {
      name = "acorn";
      packageName = "acorn";
      version = "8.14.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/acorn/-/acorn-8.14.0.tgz";
        sha512 = "cl669nCJTZBsL97OF4kUQm5g5hC2uihk0NxY3WENAC0TYdILVkAyHymAntgxGkl7K+t0cXIrH5siy5S4XkFycA==";
      };
    };
    "argparse-2.0.1" = {
      name = "argparse";
      packageName = "argparse";
      version = "2.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/argparse/-/argparse-2.0.1.tgz";
        sha512 = "8+9WqebbFzpX9OR+Wa6O29asIogeRMzcGtAINdpMHHyAg10f05aSFVBbcEqGf/PXw1EjAZ+q2/bEBg3DvurK3Q==";
      };
    };
    "bumpp-9.10.0" = {
      name = "bumpp";
      packageName = "bumpp";
      version = "9.10.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/bumpp/-/bumpp-9.10.0.tgz";
        sha512 = "gNY3tYEGKyqW8+qtpeLQ2UfQW7G81d/vhCWNGrMlvy0Toq1LZPRs8wk9woAw8o9Tzv7pvjaF/Gno+UN3qiqNxA==";
      };
    };
    "c12-2.0.1" = {
      name = "c12";
      packageName = "c12";
      version = "2.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/c12/-/c12-2.0.1.tgz";
        sha512 = "Z4JgsKXHG37C6PYUtIxCfLJZvo6FyhHJoClwwb9ftUkLpPSkuYqn6Tr+vnaN8hymm0kIbcg6Ey3kv/Q71k5w/A==";
      };
    };
    "cac-6.7.14" = {
      name = "cac";
      packageName = "cac";
      version = "6.7.14";
      src = fetchurl {
        url = "https://registry.npmjs.org/cac/-/cac-6.7.14.tgz";
        sha512 = "b6Ilus+c3RrdDk+JhLKUAQfzzgLEPy6wcXqS7f/xe1EETvsDP6GORG7SFuOs6cID5YkqchW/LXZbX5bc8j7ZcQ==";
      };
    };
    "chokidar-4.0.3" = {
      name = "chokidar";
      packageName = "chokidar";
      version = "4.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/chokidar/-/chokidar-4.0.3.tgz";
        sha512 = "Qgzu8kfBvo+cA4962jnP1KkS6Dop5NS6g7R5LFYJr4b8Ub94PPQXUksCw9PvXoeXPRRddRNC5C1JQUR2SMGtnA==";
      };
    };
    "chownr-2.0.0" = {
      name = "chownr";
      packageName = "chownr";
      version = "2.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/chownr/-/chownr-2.0.0.tgz";
        sha512 = "bIomtDF5KGpdogkLd9VspvFzk9KfpyyGlS8YFVZl7TGPBHL5snIOnxeshwVgPteQ9b4Eydl+pVbIyE1DcvCWgQ==";
      };
    };
    "citty-0.1.6" = {
      name = "citty";
      packageName = "citty";
      version = "0.1.6";
      src = fetchurl {
        url = "https://registry.npmjs.org/citty/-/citty-0.1.6.tgz";
        sha512 = "tskPPKEs8D2KPafUypv2gxwJP8h/OaJmC82QQGGDQcHvXX43xF2VDACcJVmZ0EuSxkpO9Kc4MlrA3q0+FG58AQ==";
      };
    };
    "confbox-0.1.8" = {
      name = "confbox";
      packageName = "confbox";
      version = "0.1.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/confbox/-/confbox-0.1.8.tgz";
        sha512 = "RMtmw0iFkeR4YV+fUOSucriAQNb9g8zFR52MWCtl+cCZOFRNL6zeB395vPzFhEjjn4fMxXudmELnl/KF/WrK6w==";
      };
    };
    "consola-3.3.3" = {
      name = "consola";
      packageName = "consola";
      version = "3.3.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/consola/-/consola-3.3.3.tgz";
        sha512 = "Qil5KwghMzlqd51UXM0b6fyaGHtOC22scxrwrz4A2882LyUMwQjnvaedN1HAeXzphspQ6CpHkzMAWxBTUruDLg==";
      };
    };
    "cross-spawn-7.0.6" = {
      name = "cross-spawn";
      packageName = "cross-spawn";
      version = "7.0.6";
      src = fetchurl {
        url = "https://registry.npmjs.org/cross-spawn/-/cross-spawn-7.0.6.tgz";
        sha512 = "uV2QOWP2nWzsy2aMp8aRibhi9dlzF5Hgh5SHaB9OiTGEyDTiJJyx0uy51QXdyWbtAHNua4XJzUKca3OzKUd3vA==";
      };
    };
    "defu-6.1.4" = {
      name = "defu";
      packageName = "defu";
      version = "6.1.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/defu/-/defu-6.1.4.tgz";
        sha512 = "mEQCMmwJu317oSz8CwdIOdwf3xMif1ttiM8LTufzc3g6kR+9Pe236twL8j3IYT1F7GfRgGcW6MWxzZjLIkuHIg==";
      };
    };
    "destr-2.0.3" = {
      name = "destr";
      packageName = "destr";
      version = "2.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/destr/-/destr-2.0.3.tgz";
        sha512 = "2N3BOUU4gYMpTP24s5rF5iP7BDr7uNTCs4ozw3kf/eKfvWSIu93GEBi5m427YoyJoeOzQ5smuu4nNAPGb8idSQ==";
      };
    };
    "dotenv-16.4.7" = {
      name = "dotenv";
      packageName = "dotenv";
      version = "16.4.7";
      src = fetchurl {
        url = "https://registry.npmjs.org/dotenv/-/dotenv-16.4.7.tgz";
        sha512 = "47qPchRCykZC03FhkYAhrvwU4xDBFIj1QPqaarj6mdM/hgUzfPHcpkHJOn3mJAufFeeAxAzeGsr5X0M4k6fLZQ==";
      };
    };
    "emmet-2.4.11" = {
      name = "emmet";
      packageName = "emmet";
      version = "2.4.11";
      src = fetchurl {
        url = "https://registry.npmjs.org/emmet/-/emmet-2.4.11.tgz";
        sha512 = "23QPJB3moh/U9sT4rQzGgeyyGIrcM+GH5uVYg2C6wZIxAIJq7Ng3QLT79tl8FUwDXhyq9SusfknOrofAKqvgyQ==";
      };
    };
    "escalade-3.2.0" = {
      name = "escalade";
      packageName = "escalade";
      version = "3.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/escalade/-/escalade-3.2.0.tgz";
        sha512 = "WUj2qlxaQtO4g6Pq5c29GTcWGDyd8itL8zTlipgECz3JesAiiOKotd8JU6otB3PACgG6xkJUyVhboMS+bje/jA==";
      };
    };
    "execa-8.0.1" = {
      name = "execa";
      packageName = "execa";
      version = "8.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/execa/-/execa-8.0.1.tgz";
        sha512 = "VyhnebXciFV2DESc+p6B+y0LjSm0krU4OgJN44qFAhBY0TJ+1V61tYD2+wHusZ6F9n5K+vl8k0sTy7PEfV4qpg==";
      };
    };
    "fdir-6.4.2" = {
      name = "fdir";
      packageName = "fdir";
      version = "6.4.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/fdir/-/fdir-6.4.2.tgz";
        sha512 = "KnhMXsKSPZlAhp7+IjUkRZKPb4fUyccpDrdFXbi4QL1qkmFh9kVY09Yox+n4MaOb3lHZ1Tv829C3oaaXoMYPDQ==";
      };
    };
    "fs-minipass-2.1.0" = {
      name = "fs-minipass";
      packageName = "fs-minipass";
      version = "2.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/fs-minipass/-/fs-minipass-2.1.0.tgz";
        sha512 = "V/JgOLFCS+R6Vcq0slCuaeWEdNC3ouDlJMNIsacH2VtALiu9mV4LPrHc5cDl8k5aw6J8jwgWWpiTo5RYhmIzvg==";
      };
    };
    "get-stream-8.0.1" = {
      name = "get-stream";
      packageName = "get-stream";
      version = "8.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/get-stream/-/get-stream-8.0.1.tgz";
        sha512 = "VaUJspBffn/LMCJVoMvSAdmscJyS1auj5Zulnn5UoYcY531UWmdwhRWkcGKnGU93m5HSXP9LP2usOryrBtQowA==";
      };
    };
    "giget-1.2.3" = {
      name = "giget";
      packageName = "giget";
      version = "1.2.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/giget/-/giget-1.2.3.tgz";
        sha512 = "8EHPljDvs7qKykr6uw8b+lqLiUc/vUg+KVTI0uND4s63TdsZM2Xus3mflvF0DDG9SiM4RlCkFGL+7aAjRmV7KA==";
      };
    };
    "human-signals-5.0.0" = {
      name = "human-signals";
      packageName = "human-signals";
      version = "5.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/human-signals/-/human-signals-5.0.0.tgz";
        sha512 = "AXcZb6vzzrFAUE61HnN4mpLqd/cSIwNQjtNWR0euPm6y0iqx3G4gOXaIDdtdDwZmhwe82LA6+zinmW4UBWVePQ==";
      };
    };
    "is-stream-3.0.0" = {
      name = "is-stream";
      packageName = "is-stream";
      version = "3.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/is-stream/-/is-stream-3.0.0.tgz";
        sha512 = "LnQR4bZ9IADDRSkvpqMGvt/tEJWclzklNgSw48V5EAaAeDd6qGvN8ei6k5p0tvxSR171VmGyHuTiAOfxAbr8kA==";
      };
    };
    "isexe-2.0.0" = {
      name = "isexe";
      packageName = "isexe";
      version = "2.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/isexe/-/isexe-2.0.0.tgz";
        sha512 = "RHxMLp9lnKHGHRng9QFhRCMbYAcVpn69smSGcq3f36xjgVVWThj4qqLbTLlq7Ssj8B+fIQ1EuCEGI2lKsyQeIw==";
      };
    };
    "jiti-2.4.2" = {
      name = "jiti";
      packageName = "jiti";
      version = "2.4.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/jiti/-/jiti-2.4.2.tgz";
        sha512 = "rg9zJN+G4n2nfJl5MW3BMygZX56zKPNVEYYqq7adpmMh4Jn2QNEwhvQlFy6jPVdcod7txZtKHWnyZiA3a0zP7A==";
      };
    };
    "js-yaml-4.1.0" = {
      name = "js-yaml";
      packageName = "js-yaml";
      version = "4.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/js-yaml/-/js-yaml-4.1.0.tgz";
        sha512 = "wpxZs9NoxZaJESJGIZTyDEaYpl0FKSA+FB9aJiyemKhMwkxQg63h4T1KJgUGHpTqPDNRcmmYLugrRjJlBtWvRA==";
      };
    };
    "jsonc-parser-2.3.1" = {
      name = "jsonc-parser";
      packageName = "jsonc-parser";
      version = "2.3.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/jsonc-parser/-/jsonc-parser-2.3.1.tgz";
        sha512 = "H8jvkz1O50L3dMZCsLqiuB2tA7muqbSg1AtGEkN0leAqGjsUzDJir3Zwr02BhqdcITPg3ei3mZ+HjMocAknhhg==";
      };
    };
    "jsonc-parser-3.3.1" = {
      name = "jsonc-parser";
      packageName = "jsonc-parser";
      version = "3.3.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/jsonc-parser/-/jsonc-parser-3.3.1.tgz";
        sha512 = "HUgH65KyejrUFPvHFPbqOY0rsFip3Bo5wb4ngvdi1EpCYWUQDC5V+Y7mZws+DLkr4M//zQJoanu1SP+87Dv1oQ==";
      };
    };
    "kleur-3.0.3" = {
      name = "kleur";
      packageName = "kleur";
      version = "3.0.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/kleur/-/kleur-3.0.3.tgz";
        sha512 = "eTIzlVOSUR+JxdDFepEYcBMtZ9Qqdef+rnzWdRZuMbOywu5tO2w2N7rqjoANZ5k9vywhL6Br1VRjUIgTQx4E8w==";
      };
    };
    "magicast-0.3.5" = {
      name = "magicast";
      packageName = "magicast";
      version = "0.3.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/magicast/-/magicast-0.3.5.tgz";
        sha512 = "L0WhttDl+2BOsybvEOLK7fW3UA0OQ0IQ2d6Zl2x/a6vVRs3bAY0ECOSHHeL5jD+SbOpOCUEi0y1DgHEn9Qn1AQ==";
      };
    };
    "merge-stream-2.0.0" = {
      name = "merge-stream";
      packageName = "merge-stream";
      version = "2.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/merge-stream/-/merge-stream-2.0.0.tgz";
        sha512 = "abv/qOcuPfk3URPfDzmZU1LKmuw8kT+0nIHvKrKgFrwifol/doWcdA4ZqsWQ8ENrFKkd67Mfpo/LovbIUsbt3w==";
      };
    };
    "mimic-fn-4.0.0" = {
      name = "mimic-fn";
      packageName = "mimic-fn";
      version = "4.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/mimic-fn/-/mimic-fn-4.0.0.tgz";
        sha512 = "vqiC06CuhBTUdZH+RYl8sFrL096vA45Ok5ISO6sE/Mr1jRbGH4Csnhi8f3wKVl7x8mO4Au7Ir9D3Oyv1VYMFJw==";
      };
    };
    "minipass-3.3.6" = {
      name = "minipass";
      packageName = "minipass";
      version = "3.3.6";
      src = fetchurl {
        url = "https://registry.npmjs.org/minipass/-/minipass-3.3.6.tgz";
        sha512 = "DxiNidxSEK+tHG6zOIklvNOwm3hvCrbUrdtzY74U6HKTJxvIDfOUL5W5P2Ghd3DTkhhKPYGqeNUIh5qcM4YBfw==";
      };
    };
    "minipass-5.0.0" = {
      name = "minipass";
      packageName = "minipass";
      version = "5.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/minipass/-/minipass-5.0.0.tgz";
        sha512 = "3FnjYuehv9k6ovOEbyOswadCDPX1piCfhV8ncmYtHOjuPwylVWsghTLo7rabjC3Rx5xD4HDx8Wm1xnMF7S5qFQ==";
      };
    };
    "minizlib-2.1.2" = {
      name = "minizlib";
      packageName = "minizlib";
      version = "2.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/minizlib/-/minizlib-2.1.2.tgz";
        sha512 = "bAxsR8BVfj60DWXHE3u30oHzfl4G7khkSuPW+qvpd7jFRHm7dLxOjUk1EHACJ/hxLY8phGJ0YhYHZo7jil7Qdg==";
      };
    };
    "mkdirp-1.0.4" = {
      name = "mkdirp";
      packageName = "mkdirp";
      version = "1.0.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/mkdirp/-/mkdirp-1.0.4.tgz";
        sha512 = "vVqVZQyf3WLx2Shd0qJ9xuvqgAyKPLAiqITEtqW0oIUjzo3PePDd6fW9iFz30ef7Ysp/oiWqbhszeGWW2T6Gzw==";
      };
    };
    "mlly-1.7.3" = {
      name = "mlly";
      packageName = "mlly";
      version = "1.7.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/mlly/-/mlly-1.7.3.tgz";
        sha512 = "xUsx5n/mN0uQf4V548PKQ+YShA4/IW0KI1dZhrNrPCLG+xizETbHTkOa1f8/xut9JRPp8kQuMnz0oqwkTiLo/A==";
      };
    };
    "node-fetch-native-1.6.4" = {
      name = "node-fetch-native";
      packageName = "node-fetch-native";
      version = "1.6.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/node-fetch-native/-/node-fetch-native-1.6.4.tgz";
        sha512 = "IhOigYzAKHd244OC0JIMIUrjzctirCmPkaIfhDeGcEETWof5zKYUW7e7MYvChGWh/4CJeXEgsRyGzuF334rOOQ==";
      };
    };
    "npm-run-path-5.3.0" = {
      name = "npm-run-path";
      packageName = "npm-run-path";
      version = "5.3.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/npm-run-path/-/npm-run-path-5.3.0.tgz";
        sha512 = "ppwTtiJZq0O/ai0z7yfudtBpWIoxM8yE6nHi1X47eFR2EWORqfbu6CnPlNsjeN683eT0qG6H/Pyf9fCcvjnnnQ==";
      };
    };
    "nypm-0.3.12" = {
      name = "nypm";
      packageName = "nypm";
      version = "0.3.12";
      src = fetchurl {
        url = "https://registry.npmjs.org/nypm/-/nypm-0.3.12.tgz";
        sha512 = "D3pzNDWIvgA+7IORhD/IuWzEk4uXv6GsgOxiid4UU3h9oq5IqV1KtPDi63n4sZJ/xcWlr88c0QM2RgN5VbOhFA==";
      };
    };
    "ohash-1.1.4" = {
      name = "ohash";
      packageName = "ohash";
      version = "1.1.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/ohash/-/ohash-1.1.4.tgz";
        sha512 = "FlDryZAahJmEF3VR3w1KogSEdWX3WhA5GPakFx4J81kEAiHyLMpdLLElS8n8dfNadMgAne/MywcvmogzscVt4g==";
      };
    };
    "onetime-6.0.0" = {
      name = "onetime";
      packageName = "onetime";
      version = "6.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/onetime/-/onetime-6.0.0.tgz";
        sha512 = "1FlR+gjXK7X+AsAHso35MnyN5KqGwJRi/31ft6x0M194ht7S+rWAvd7PHss9xSKMzE0asv1pyIHaJYq+BbacAQ==";
      };
    };
    "package-manager-detector-0.2.8" = {
      name = "package-manager-detector";
      packageName = "package-manager-detector";
      version = "0.2.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/package-manager-detector/-/package-manager-detector-0.2.8.tgz";
        sha512 = "ts9KSdroZisdvKMWVAVCXiKqnqNfXz4+IbrBG8/BWx/TR5le+jfenvoBuIZ6UWM9nz47W7AbD9qYfAwfWMIwzA==";
      };
    };
    "path-key-3.1.1" = {
      name = "path-key";
      packageName = "path-key";
      version = "3.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/path-key/-/path-key-3.1.1.tgz";
        sha512 = "ojmeN0qd+y0jszEtoY48r0Peq5dwMEkIlCOu6Q5f41lfkswXuKtYrhgoTpLnyIcHm24Uhqx+5Tqm2InSwLhE6Q==";
      };
    };
    "path-key-4.0.0" = {
      name = "path-key";
      packageName = "path-key";
      version = "4.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/path-key/-/path-key-4.0.0.tgz";
        sha512 = "haREypq7xkM7ErfgIyA0z+Bj4AGKlMSdlQE2jvJo6huWD1EdkKYV+G/T4nq0YEF2vgTT8kqMFKo1uHn950r4SQ==";
      };
    };
    "pathe-1.1.2" = {
      name = "pathe";
      packageName = "pathe";
      version = "1.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/pathe/-/pathe-1.1.2.tgz";
        sha512 = "whLdWMYL2TwI08hn8/ZqAbrVemu0LNaNNJZX73O6qaIdCTfXutsLhMkjdENX0qhsQ9uIimo4/aQOmXkoon2nDQ==";
      };
    };
    "perfect-debounce-1.0.0" = {
      name = "perfect-debounce";
      packageName = "perfect-debounce";
      version = "1.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/perfect-debounce/-/perfect-debounce-1.0.0.tgz";
        sha512 = "xCy9V055GLEqoFaHoC1SoLIaLmWctgCUaBaWxDZ7/Zx4CTyX7cJQLJOok/orfjZAh9kEYpjJa4d0KcJmCbctZA==";
      };
    };
    "picomatch-4.0.2" = {
      name = "picomatch";
      packageName = "picomatch";
      version = "4.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/picomatch/-/picomatch-4.0.2.tgz";
        sha512 = "M7BAV6Rlcy5u+m6oPhAPFgJTzAioX/6B0DxyvDlo9l8+T3nLKbrczg2WLUyzd45L8RqfUMyGPzekbMvX2Ldkwg==";
      };
    };
    "pkg-types-1.3.0" = {
      name = "pkg-types";
      packageName = "pkg-types";
      version = "1.3.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/pkg-types/-/pkg-types-1.3.0.tgz";
        sha512 = "kS7yWjVFCkIw9hqdJBoMxDdzEngmkr5FXeWZZfQ6GoYacjVnsW6l2CcYW/0ThD0vF4LPJgVYnrg4d0uuhwYQbg==";
      };
    };
    "prompts-2.4.2" = {
      name = "prompts";
      packageName = "prompts";
      version = "2.4.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/prompts/-/prompts-2.4.2.tgz";
        sha512 = "NxNv/kLguCA7p3jE8oL2aEBsrJWgAakBpgmgK6lpPWV+WuOmY6r2/zbAVnP+T8bQlA0nzHXSJSJW0Hq7ylaD2Q==";
      };
    };
    "rc9-2.1.2" = {
      name = "rc9";
      packageName = "rc9";
      version = "2.1.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/rc9/-/rc9-2.1.2.tgz";
        sha512 = "btXCnMmRIBINM2LDZoEmOogIZU7Qe7zn4BpomSKZ/ykbLObuBdvG+mFq11DL6fjH1DRwHhrlgtYWG96bJiC7Cg==";
      };
    };
    "readdirp-4.1.1" = {
      name = "readdirp";
      packageName = "readdirp";
      version = "4.1.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/readdirp/-/readdirp-4.1.1.tgz";
        sha512 = "h80JrZu/MHUZCyHu5ciuoI0+WxsCxzxJTILn6Fs8rxSnFPh+UVHYfeIxK1nVGugMqkfC4vJcBOYbkfkwYK0+gw==";
      };
    };
    "semver-7.6.3" = {
      name = "semver";
      packageName = "semver";
      version = "7.6.3";
      src = fetchurl {
        url = "https://registry.npmjs.org/semver/-/semver-7.6.3.tgz";
        sha512 = "oVekP1cKtI+CTDvHWYFUcMtsK/00wmAEfyqKfNdARm8u1wNVhSgaX7A8d4UuIlUI5e84iEwOhs7ZPYRmzU9U6A==";
      };
    };
    "shebang-command-2.0.0" = {
      name = "shebang-command";
      packageName = "shebang-command";
      version = "2.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/shebang-command/-/shebang-command-2.0.0.tgz";
        sha512 = "kHxr2zZpYtdmrN1qDjrrX/Z1rR1kG8Dx+gkpK1G4eXmvXswmcE1hTWBWYUzlraYw1/yZp6YuDY77YtvbN0dmDA==";
      };
    };
    "shebang-regex-3.0.0" = {
      name = "shebang-regex";
      packageName = "shebang-regex";
      version = "3.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/shebang-regex/-/shebang-regex-3.0.0.tgz";
        sha512 = "7++dFhtcx3353uBaq8DDR4NuxBetBzC7ZQOhmTQInHEd6bSrXdiEyzCvG07Z44UYdLShWUyXt5M/yhz8ekcb1A==";
      };
    };
    "signal-exit-4.1.0" = {
      name = "signal-exit";
      packageName = "signal-exit";
      version = "4.1.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/signal-exit/-/signal-exit-4.1.0.tgz";
        sha512 = "bzyZ1e88w9O1iNJbKnOlvYTrWPDl46O1bG0D3XInv+9tkPrxrN8jUUTiFlDkkmKWgn1M6CfIA13SuGqOa9Korw==";
      };
    };
    "sisteransi-1.0.5" = {
      name = "sisteransi";
      packageName = "sisteransi";
      version = "1.0.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/sisteransi/-/sisteransi-1.0.5.tgz";
        sha512 = "bLGGlR1QxBcynn2d5YmDX4MGjlZvy2MRBDRNHLJ8VI6l6+9FUiyTFNJ0IveOSP0bcXgVDPRcfGqA0pjaqUpfVg==";
      };
    };
    "source-map-js-1.2.1" = {
      name = "source-map-js";
      packageName = "source-map-js";
      version = "1.2.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/source-map-js/-/source-map-js-1.2.1.tgz";
        sha512 = "UXWMKhLOwVKb728IUtQPXxfYU+usdybtUrK/8uGE8CQMvrhOpwvzDBwj0QhSL7MQc7vIsISBG8VQ8+IDQxpfQA==";
      };
    };
    "strip-final-newline-3.0.0" = {
      name = "strip-final-newline";
      packageName = "strip-final-newline";
      version = "3.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/strip-final-newline/-/strip-final-newline-3.0.0.tgz";
        sha512 = "dOESqjYr96iWYylGObzd39EuNTa5VJxyvVAEm5Jnh7KGo75V43Hk1odPQkNDyXNmUR6k+gEiDVXnjB8HJ3crXw==";
      };
    };
    "tar-6.2.1" = {
      name = "tar";
      packageName = "tar";
      version = "6.2.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/tar/-/tar-6.2.1.tgz";
        sha512 = "DZ4yORTwrbTj/7MZYq2w+/ZFdI6OZ/f9SFHR+71gIVUZhOQPHzVCLpvRnPgyaMpfWxxk/4ONva3GQSyNIKRv6A==";
      };
    };
    "tinyexec-0.3.2" = {
      name = "tinyexec";
      packageName = "tinyexec";
      version = "0.3.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/tinyexec/-/tinyexec-0.3.2.tgz";
        sha512 = "KQQR9yN7R5+OSwaK0XQoj22pwHoTlgYqmUscPYoknOoWCWfj/5/ABTMRi69FrKU5ffPVh5QcFikpWJI/P1ocHA==";
      };
    };
    "tinyglobby-0.2.10" = {
      name = "tinyglobby";
      packageName = "tinyglobby";
      version = "0.2.10";
      src = fetchurl {
        url = "https://registry.npmjs.org/tinyglobby/-/tinyglobby-0.2.10.tgz";
        sha512 = "Zc+8eJlFMvgatPZTl6A9L/yht8QqdmUNtURHaKZLmKBE12hNPSrqNkUp2cs3M/UKmNVVAMFQYSjYIVHDjW5zew==";
      };
    };
    "typescript-4.9.5" = {
      name = "typescript";
      packageName = "typescript";
      version = "4.9.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/typescript/-/typescript-4.9.5.tgz";
        sha512 = "1FXk9E2Hm+QzZQ7z+McJiHL4NW1F2EzMu9Nq9i3zAaGqibafqYwCVU6WyWAuyQRRzOlxou8xZSyXLEN8oKj24g==";
      };
    };
    "ufo-1.5.4" = {
      name = "ufo";
      packageName = "ufo";
      version = "1.5.4";
      src = fetchurl {
        url = "https://registry.npmjs.org/ufo/-/ufo-1.5.4.tgz";
        sha512 = "UsUk3byDzKd04EyoZ7U4DOlxQaD14JUKQl6/P7wiX4FNvUfm3XL246n9W5AmqwW5RSFJ27NAuM0iLscAOYUiGQ==";
      };
    };
    "vscode-jsonrpc-6.0.0" = {
      name = "vscode-jsonrpc";
      packageName = "vscode-jsonrpc";
      version = "6.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-jsonrpc/-/vscode-jsonrpc-6.0.0.tgz";
        sha512 = "wnJA4BnEjOSyFMvjZdpiOwhSq9uDoK8e/kpRJDTaMYzwlkrhG1fwDIZI94CLsLzlCK5cIbMMtFlJlfR57Lavmg==";
      };
    };
    "vscode-jsonrpc-8.2.0" = {
      name = "vscode-jsonrpc";
      packageName = "vscode-jsonrpc";
      version = "8.2.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-jsonrpc/-/vscode-jsonrpc-8.2.0.tgz";
        sha512 = "C+r0eKJUIfiDIfwJhria30+TYWPtuHJXHtI7J0YlOmKAo7ogxP20T0zxB7HZQIFhIyvoBPwWskjxrvAtfjyZfA==";
      };
    };
    "vscode-languageserver-7.0.0" = {
      name = "vscode-languageserver";
      packageName = "vscode-languageserver";
      version = "7.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver/-/vscode-languageserver-7.0.0.tgz";
        sha512 = "60HTx5ID+fLRcgdHfmz0LDZAXYEV68fzwG0JWwEPBode9NuMYTIxuYXPg4ngO8i8+Ou0lM7y6GzaYWbiDL0drw==";
      };
    };
    "vscode-languageserver-9.0.1" = {
      name = "vscode-languageserver";
      packageName = "vscode-languageserver";
      version = "9.0.1";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver/-/vscode-languageserver-9.0.1.tgz";
        sha512 = "woByF3PDpkHFUreUa7Hos7+pUWdeWMXRd26+ZX2A8cFx6v/JPTtd4/uN0/jB6XQHYaOlHbio03NTHCqrgG5n7g==";
      };
    };
    "vscode-languageserver-protocol-3.16.0" = {
      name = "vscode-languageserver-protocol";
      packageName = "vscode-languageserver-protocol";
      version = "3.16.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-protocol/-/vscode-languageserver-protocol-3.16.0.tgz";
        sha512 = "sdeUoAawceQdgIfTI+sdcwkiK2KU+2cbEYA0agzM2uqaUy2UpnnGHtWTHVEtS0ES4zHU0eMFRGN+oQgDxlD66A==";
      };
    };
    "vscode-languageserver-protocol-3.17.5" = {
      name = "vscode-languageserver-protocol";
      packageName = "vscode-languageserver-protocol";
      version = "3.17.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-protocol/-/vscode-languageserver-protocol-3.17.5.tgz";
        sha512 = "mb1bvRJN8SVznADSGWM9u/b07H7Ecg0I3OgXDuLdn307rl/J3A9YD6/eYOssqhecL27hK1IPZAsaqh00i/Jljg==";
      };
    };
    "vscode-languageserver-textdocument-1.0.12" = {
      name = "vscode-languageserver-textdocument";
      packageName = "vscode-languageserver-textdocument";
      version = "1.0.12";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-textdocument/-/vscode-languageserver-textdocument-1.0.12.tgz";
        sha512 = "cxWNPesCnQCcMPeenjKKsOCKQZ/L6Tv19DTRIGuLWe32lyzWhihGVJ/rcckZXJxfdKCFvRLS3fpBIsV/ZGX4zA==";
      };
    };
    "vscode-languageserver-types-3.16.0" = {
      name = "vscode-languageserver-types";
      packageName = "vscode-languageserver-types";
      version = "3.16.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-types/-/vscode-languageserver-types-3.16.0.tgz";
        sha512 = "k8luDIWJWyenLc5ToFQQMaSrqCHiLwyKPHKPQZ5zz21vM+vIVUSvsRpcbiECH4WR88K2XZqc4ScRcZ7nk/jbeA==";
      };
    };
    "vscode-languageserver-types-3.17.5" = {
      name = "vscode-languageserver-types";
      packageName = "vscode-languageserver-types";
      version = "3.17.5";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-languageserver-types/-/vscode-languageserver-types-3.17.5.tgz";
        sha512 = "Ld1VelNuX9pdF39h2Hgaeb5hEZM2Z3jUrrMgWQAu82jMtZp7p3vJT3BzToKtZI7NgQssZje5o0zryOrhQvzQAg==";
      };
    };
    "vscode-uri-3.0.8" = {
      name = "vscode-uri";
      packageName = "vscode-uri";
      version = "3.0.8";
      src = fetchurl {
        url = "https://registry.npmjs.org/vscode-uri/-/vscode-uri-3.0.8.tgz";
        sha512 = "AyFQ0EVmsOZOlAnxoFOGOq1SQDWAB7C6aqMGS23svWAllfOaxbuFvcT8D1i8z3Gyn8fraVeZNNmN6e9bxxXkKw==";
      };
    };
    "which-2.0.2" = {
      name = "which";
      packageName = "which";
      version = "2.0.2";
      src = fetchurl {
        url = "https://registry.npmjs.org/which/-/which-2.0.2.tgz";
        sha512 = "BLI3Tl1TW3Pvl70l3yq3Y64i+awpwXqsGBYWkkqMtnbXgrMD+yj7rhW0kuEDxzJaYXGjEW5ogapKNMEKNMjibA==";
      };
    };
    "yallist-4.0.0" = {
      name = "yallist";
      packageName = "yallist";
      version = "4.0.0";
      src = fetchurl {
        url = "https://registry.npmjs.org/yallist/-/yallist-4.0.0.tgz";
        sha512 = "3wdGidZyq5PB084XLES5TpOSRA3wjXAlIWMhum2kRcv/41Sn2emQ0dycQW4uZXLejwKvg6EsvbdlVL+FYEct7A==";
      };
    };
  };
in {
  "@tailwindcss/language-server" = nodeEnv.buildNodePackage {
    name = "_at_tailwindcss_slash_language-server";
    packageName = "@tailwindcss/language-server";
    version = "0.12.18";
    src = fetchurl {
      url = "https://registry.npmjs.org/@tailwindcss/language-server/-/language-server-0.12.18.tgz";
      sha512 = "v69+026Ynq5gwtZAwUBTcRP7OHHSLu8ztgXKzzhSRmZiK9UGemlnHI4ZFDwn2uSsE4oW2VyWRxu3j2Kb5bDiJw==";
    };
    buildInputs = globalBuildInputs;
    meta = {
      description = "Tailwind CSS Language Server";
      homepage = "https://github.com/tailwindlabs/tailwindcss-intellisense/tree/HEAD/packages/tailwindcss-language-server#readme";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
  emmet-ls = nodeEnv.buildNodePackage {
    name = "emmet-ls";
    packageName = "emmet-ls";
    version = "0.4.2";
    src = fetchurl {
      url = "https://registry.npmjs.org/emmet-ls/-/emmet-ls-0.4.2.tgz";
      sha512 = "nwiUsbph9c4TkZjrKb7OqrUG6XQ3AxmmVn3IDR6FTx/xLLAegpmSxfOrvvPADbz9vOkSP6jjShpux1tNrqqIkQ==";
    };
    dependencies = [
      sources."@emmetio/abbreviation-2.3.3"
      sources."@emmetio/css-abbreviation-2.1.8"
      sources."@emmetio/scanner-1.0.4"
      sources."@types/node-17.0.45"
      sources."emmet-2.4.11"
      sources."typescript-4.9.5"
      sources."vscode-jsonrpc-6.0.0"
      sources."vscode-languageserver-7.0.0"
      sources."vscode-languageserver-protocol-3.16.0"
      sources."vscode-languageserver-textdocument-1.0.12"
      sources."vscode-languageserver-types-3.16.0"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "emmet support by LSP";
      homepage = "https://github.com/aca/emmet-ls#readme";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
  "@olrtg/emmet-language-server" = nodeEnv.buildNodePackage {
    name = "_at_olrtg_slash_emmet-language-server";
    packageName = "@olrtg/emmet-language-server";
    version = "2.6.1";
    src = fetchurl {
      url = "https://registry.npmjs.org/@olrtg/emmet-language-server/-/emmet-language-server-2.6.1.tgz";
      sha512 = "Ie5uRQLJakzDxncCnzmghypOaLxcgbfU8vP30qbNrukg+b2bBp05w0acBDm9Bz/JPgCzbVtcbKnci+gxIUjYQA==";
    };
    dependencies = [
      sources."@babel/helper-string-parser-7.25.9"
      sources."@babel/helper-validator-identifier-7.25.9"
      sources."@babel/parser-7.26.5"
      sources."@babel/types-7.26.5"
      sources."@emmetio/abbreviation-2.3.3"
      sources."@emmetio/css-abbreviation-2.1.8"
      sources."@emmetio/scanner-1.0.4"
      sources."@vscode/emmet-helper-2.11.0"
      sources."acorn-8.14.0"
      sources."argparse-2.0.1"
      (sources."bumpp-9.10.0"
        // {
          dependencies = [
            sources."jsonc-parser-3.3.1"
          ];
        })
      sources."c12-2.0.1"
      sources."cac-6.7.14"
      sources."chokidar-4.0.3"
      sources."chownr-2.0.0"
      sources."citty-0.1.6"
      sources."confbox-0.1.8"
      sources."consola-3.3.3"
      sources."cross-spawn-7.0.6"
      sources."defu-6.1.4"
      sources."destr-2.0.3"
      sources."dotenv-16.4.7"
      sources."emmet-2.4.11"
      sources."escalade-3.2.0"
      sources."execa-8.0.1"
      sources."fdir-6.4.2"
      (sources."fs-minipass-2.1.0"
        // {
          dependencies = [
            sources."minipass-3.3.6"
          ];
        })
      sources."get-stream-8.0.1"
      sources."giget-1.2.3"
      sources."human-signals-5.0.0"
      sources."is-stream-3.0.0"
      sources."isexe-2.0.0"
      sources."jiti-2.4.2"
      sources."js-yaml-4.1.0"
      sources."jsonc-parser-2.3.1"
      sources."kleur-3.0.3"
      sources."magicast-0.3.5"
      sources."merge-stream-2.0.0"
      sources."mimic-fn-4.0.0"
      sources."minipass-5.0.0"
      (sources."minizlib-2.1.2"
        // {
          dependencies = [
            sources."minipass-3.3.6"
          ];
        })
      sources."mkdirp-1.0.4"
      sources."mlly-1.7.3"
      sources."node-fetch-native-1.6.4"
      (sources."npm-run-path-5.3.0"
        // {
          dependencies = [
            sources."path-key-4.0.0"
          ];
        })
      sources."nypm-0.3.12"
      sources."ohash-1.1.4"
      sources."onetime-6.0.0"
      sources."package-manager-detector-0.2.8"
      sources."path-key-3.1.1"
      sources."pathe-1.1.2"
      sources."perfect-debounce-1.0.0"
      sources."picomatch-4.0.2"
      sources."pkg-types-1.3.0"
      sources."prompts-2.4.2"
      sources."rc9-2.1.2"
      sources."readdirp-4.1.1"
      sources."semver-7.6.3"
      sources."shebang-command-2.0.0"
      sources."shebang-regex-3.0.0"
      sources."signal-exit-4.1.0"
      sources."sisteransi-1.0.5"
      sources."source-map-js-1.2.1"
      sources."strip-final-newline-3.0.0"
      sources."tar-6.2.1"
      sources."tinyexec-0.3.2"
      sources."tinyglobby-0.2.10"
      sources."ufo-1.5.4"
      sources."vscode-jsonrpc-8.2.0"
      sources."vscode-languageserver-9.0.1"
      sources."vscode-languageserver-protocol-3.17.5"
      sources."vscode-languageserver-textdocument-1.0.12"
      sources."vscode-languageserver-types-3.17.5"
      sources."vscode-uri-3.0.8"
      sources."which-2.0.2"
      sources."yallist-4.0.0"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "A language server for emmet.io";
      homepage = "https://github.com/olrtg/emmet-language-server#readme";
      license = "MIT";
    };
    production = true;
    bypassCache = true;
    reconstructLock = true;
  };
}
