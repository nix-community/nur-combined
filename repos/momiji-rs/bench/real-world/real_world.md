# Real-world corpus: sasso vs dart-sass

Well-known open-source Sass codebases, each pinned to its default-branch HEAD
as of 2026-07-04 (batch 2: 2026-07-05) and verified active (last commit within
six months). Each entry
point is compiled standalone with both engines; output parity is checked after
whitespace + color-serialization canonicalization (`bench/scripts/`).

- dart-sass: `1.101.0 compiled with dart2js 3.12.2` (npm `sass`, invoked via its CLI)
- sasso: `sasso 0.7.0` (release build, this repo)
- timing: hyperfine, 2 warmup + ≥10 runs, full CLI invocation (median)

Process-startup baseline (empty input): dart-sass 137 ms, sasso 2 ms. Full-invocation medians below include this cost — it is what a CLI/CI user experiences per call.

| project | stars | pin | sass sources | dart-sass | sasso | speedup | output parity |
|---|---|---|---|---|---|---|---|
| [bootstrap](https://github.com/twbs/bootstrap) | 174,424 | `d35950e` | 99 files / 344 KB | 606 ms | 92 ms | **6.6×** | byte-identical |
| [bulma](https://github.com/jgthms/bulma) | 50,072 | `741da22` | 182 files / 1078 KB | 1297 ms | 204 ms | **6.4×** | byte-identical |
| [govuk-frontend](https://github.com/alphagov/govuk-frontend) | 1,420 | `cfd2224` | 304 files / 276 KB | 399 ms | 38 ms | **10.6×** | byte-identical |
| [uswds](https://github.com/uswds/uswds) | 7,123 | `95717ff` | 605 files / 800 KB | 3167 ms | 550 ms | **5.8×** | byte-identical |
| [carbon](https://github.com/carbon-design-system/carbon) | 9,258 | `f1d6bbf` | 291 files / 1071 KB | — | — | **—** | excluded (see projects.json) |
| [primer-css](https://github.com/primer/css) | 12,983 | `17fa611` | 113 files / 216 KB | 512 ms | 33 ms | **15.4×** | byte-identical |
| [vuetify](https://github.com/vuetifyjs/vuetify) | 41,009 | `998fe6a` | 44 files / 76 KB | 483 ms | 36 ms | **13.4×** | byte-identical |
| [quasar](https://github.com/quasarframework/quasar) | 27,189 | `4202048` | 92 files / 223 KB | 486 ms | 140 ms | **3.5×** | byte-identical |
| [mastodon](https://github.com/mastodon/mastodon) | 50,088 | `163f96c` | 31 files / 343 KB | 375 ms | 18 ms | **21.1×** | byte-identical |
| [minimal-mistakes](https://github.com/mmistakes/minimal-mistakes) | 13,540 | `58d9185` | 74 files / 225 KB | 388 ms | 21 ms | **18.9×** | byte-identical |
| [just-the-docs](https://github.com/just-the-docs/just-the-docs) | 9,079 | `2aaf003` | 35 files / 66 KB | 272 ms | 7 ms | **37.6×** | byte-identical |
| [tabler](https://github.com/tabler/tabler) | 41,263 | `d8bbb1e` | 180 files / 503 KB | 717 ms | 201 ms | **3.6×** | byte-identical |
| [adminlte](https://github.com/ColorlibHQ/AdminLTE) | 45,488 | `1b5a9c4` | 36 files / 89 KB | 703 ms | 119 ms | **5.9×** | byte-identical |
| [reveal.js](https://github.com/hakimel/reveal.js) | 71,877 | `a3b9406` | 21 files / 88 KB | 216 ms | 5 ms | **42.1×** | byte-identical |
| [font-awesome](https://github.com/FortAwesome/Font-Awesome) | 76,715 | `70fb2dd` | 20 files / 259 KB | 281 ms | 21 ms | **13.2×** | byte-identical |
| [video.js](https://github.com/videojs/video.js) | 39,805 | `1ce2b21` | 44 files / 52 KB | 231 ms | 10 ms | **23.4×** | byte-identical |
| [forem](https://github.com/forem/forem) | 22,738 | `b847ed1` | 136 files / 469 KB | 431 ms | 59 ms | **7.3×** | byte-identical |
| [nextcloud](https://github.com/nextcloud/server) | 36,034 | `4d3b85a` | 18 files / 104 KB | 302 ms | 9 ms | **33.3×** | byte-identical |
| [chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) | 10,142 | `01c62bc` | 31 files / 68 KB | 265 ms | 19 ms | **14.1×** | byte-identical |
| [grafana](https://github.com/grafana/grafana) | 75,312 | `29b4e11` | 8 files / 109 KB | 251 ms | 8 ms | **29.7×** | byte-identical |
| [wagtail](https://github.com/wagtail/wagtail) | 20,385 | `6e0e6d9` | 128 files / 234 KB | 377 ms | 21 ms | **18.1×** | byte-identical |

Regenerate: `node bench/real-world/run.mjs all`.
