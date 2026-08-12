{ config, lib, pkgs, ... }:

{
    name = "chainner";
    packageName = "chainner";
    version = "0.13.0";
    src = fetchFromGitHub {
      owner = "chaiNNer-org";
      repo = "chaiNNer";
      rev = "v${commonMeta.version}";
      sha256 = "0000000000000000000000000000000000000000000000000000";
    };
    dependencies = [
      sources."@ampproject/remapping-2.1.2"
      sources."@babel/code-frame-7.16.7"
      sources."@babel/compat-data-7.17.10"
      (sources."@babel/core-7.18.2" // {
        dependencies = [
          sources."semver-6.3.0"
        ];
      })
      sources."@babel/generator-7.18.2"
      sources."@babel/helper-annotate-as-pure-7.16.7"
      (sources."@babel/helper-compilation-targets-7.18.2" // {
        dependencies = [
          sources."semver-6.3.0"
        ];
      })
      sources."@babel/helper-create-class-features-plugin-7.18.0"
      sources."@babel/helper-environment-visitor-7.18.2"
      sources."@babel/helper-function-name-7.17.9"
      sources."@babel/helper-hoist-variables-7.16.7"
      sources."@babel/helper-member-expression-to-functions-7.17.7"
      sources."@babel/helper-module-imports-7.16.7"
      sources."@babel/helper-module-transforms-7.18.0"
      sources."@babel/helper-optimise-call-expression-7.16.7"
      sources."@babel/helper-plugin-utils-7.17.12"
      sources."@babel/helper-replace-supers-7.18.2"
      sources."@babel/helper-simple-access-7.18.2"
      sources."@babel/helper-split-export-declaration-7.16.7"
      sources."@babel/helper-validator-identifier-7.16.7"
      sources."@babel/helper-validator-option-7.16.7"
      sources."@babel/helpers-7.18.2"
      sources."@babel/highlight-7.16.10"
      sources."@babel/parser-7.18.4"
      sources."@babel/plugin-syntax-async-generators-7.8.4"
      sources."@babel/plugin-syntax-bigint-7.8.3"
      sources."@babel/plugin-syntax-class-properties-7.12.13"
      sources."@babel/plugin-syntax-import-meta-7.10.4"
      sources."@babel/plugin-syntax-json-strings-7.8.3"
      sources."@babel/plugin-syntax-jsx-7.17.12"
      sources."@babel/plugin-syntax-logical-assignment-operators-7.10.4"
      sources."@babel/plugin-syntax-nullish-coalescing-operator-7.8.3"
      sources."@babel/plugin-syntax-numeric-separator-7.10.4"
      sources."@babel/plugin-syntax-object-rest-spread-7.8.3"
      sources."@babel/plugin-syntax-optional-catch-binding-7.8.3"
      sources."@babel/plugin-syntax-optional-chaining-7.8.3"
      sources."@babel/plugin-syntax-top-level-await-7.14.5"
      sources."@babel/plugin-syntax-typescript-7.17.12"
      sources."@babel/plugin-transform-react-display-name-7.16.7"
      sources."@babel/plugin-transform-react-jsx-7.17.12"
      sources."@babel/plugin-transform-react-jsx-development-7.16.7"
      sources."@babel/plugin-transform-react-pure-annotations-7.16.7"
      sources."@babel/plugin-transform-typescript-7.18.4"
      sources."@babel/preset-react-7.17.12"
      sources."@babel/preset-typescript-7.17.12"
      sources."@babel/runtime-7.18.9"
      sources."@babel/runtime-corejs3-7.17.2"
      sources."@babel/template-7.16.7"
      sources."@babel/traverse-7.18.2"
      sources."@babel/types-7.18.4"
      sources."@bcoe/v8-coverage-0.2.3"
      sources."@chainner/navi-0.1.0"
      sources."@chakra-ui/accordion-2.0.2"
      sources."@chakra-ui/alert-2.0.1"
      sources."@chakra-ui/anatomy-2.0.0"
      sources."@chakra-ui/avatar-2.0.2"
      sources."@chakra-ui/breadcrumb-2.0.1"
      sources."@chakra-ui/button-2.0.1"
      sources."@chakra-ui/checkbox-2.0.2"
      sources."@chakra-ui/clickable-2.0.1"
      sources."@chakra-ui/close-button-2.0.1"
      sources."@chakra-ui/color-mode-2.0.3"
      sources."@chakra-ui/control-box-2.0.1"
      sources."@chakra-ui/counter-2.0.1"
      sources."@chakra-ui/css-reset-2.0.0"
      sources."@chakra-ui/descendant-3.0.1"
      sources."@chakra-ui/editable-2.0.1"
      sources."@chakra-ui/focus-lock-2.0.2"
      sources."@chakra-ui/form-control-2.0.1"
      sources."@chakra-ui/hooks-2.0.1"
      sources."@chakra-ui/icon-3.0.1"
      sources."@chakra-ui/icons-2.0.1"
      sources."@chakra-ui/image-2.0.2"
      sources."@chakra-ui/input-2.0.1"
      sources."@chakra-ui/layout-2.0.1"
      sources."@chakra-ui/live-region-2.0.1"
      sources."@chakra-ui/media-query-3.0.2"
      sources."@chakra-ui/menu-2.0.2"
      sources."@chakra-ui/modal-2.0.2"
      sources."@chakra-ui/number-input-2.0.1"
      sources."@chakra-ui/pin-input-2.0.2"
      sources."@chakra-ui/popover-2.0.1"
      sources."@chakra-ui/popper-3.0.1"
      sources."@chakra-ui/portal-2.0.1"
      sources."@chakra-ui/progress-2.0.1"
      sources."@chakra-ui/provider-2.0.4"
      sources."@chakra-ui/radio-2.0.1"
      sources."@chakra-ui/react-2.1.2"
      sources."@chakra-ui/react-env-2.0.1"
      sources."@chakra-ui/react-utils-2.0.0"
      sources."@chakra-ui/select-2.0.1"
      sources."@chakra-ui/skeleton-2.0.4"
      sources."@chakra-ui/slider-2.0.1"
      sources."@chakra-ui/spinner-2.0.1"
      sources."@chakra-ui/stat-2.0.1"
      sources."@chakra-ui/styled-system-2.1.1"
      sources."@chakra-ui/switch-2.0.2"
      sources."@chakra-ui/system-2.1.1"
      sources."@chakra-ui/table-2.0.1"
      sources."@chakra-ui/tabs-2.0.2"
      sources."@chakra-ui/tag-2.0.1"
      sources."@chakra-ui/textarea-2.0.2"
      sources."@chakra-ui/theme-2.0.3"
      sources."@chakra-ui/theme-tools-2.0.1"
      sources."@chakra-ui/toast-2.0.5"
      sources."@chakra-ui/tooltip-2.0.1"
      sources."@chakra-ui/transition-2.0.1"
      sources."@chakra-ui/utils-2.0.1"
      sources."@chakra-ui/visually-hidden-2.0.1"
      (sources."@cspotcode/source-map-support-0.8.1" // {
        dependencies = [
          sources."@jridgewell/trace-mapping-0.3.9"
        ];
      })
      sources."@csstools/selector-specificity-2.0.2"
      sources."@ctrl/tinycolor-3.4.1"
      (sources."@electron-forge/async-ora-6.0.0-beta.67" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."@electron-forge/cli-6.0.0-beta.67" // {
        dependencies = [
          (sources."@electron/get-2.0.1" // {
            dependencies = [
              sources."fs-extra-8.1.0"
              sources."semver-6.3.0"
            ];
          })
          sources."@sindresorhus/is-4.6.0"
          sources."@szmarczak/http-timer-4.0.6"
          sources."ansi-styles-4.3.0"
          sources."cacheable-request-7.0.2"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."decompress-response-6.0.0"
          sources."defer-to-connect-2.0.1"
          sources."get-stream-5.2.0"
          sources."got-11.8.5"
          sources."has-flag-4.0.0"
          sources."json-buffer-3.0.1"
          sources."jsonfile-4.0.0"
          sources."keyv-4.5.0"
          sources."lowercase-keys-2.0.0"
          sources."mimic-response-3.1.0"
          sources."normalize-url-6.1.0"
          sources."p-cancelable-2.1.1"
          sources."responselike-2.0.1"
          sources."supports-color-7.2.0"
          sources."universalify-0.1.2"
        ];
      })
      (sources."@electron-forge/core-6.0.0-beta.67" // {
        dependencies = [
          (sources."@electron/get-2.0.1" // {
            dependencies = [
              sources."fs-extra-8.1.0"
              sources."semver-6.3.0"
            ];
          })
          sources."@sindresorhus/is-4.6.0"
          sources."@szmarczak/http-timer-4.0.6"
          sources."ansi-styles-4.3.0"
          sources."cacheable-request-7.0.2"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."decompress-response-6.0.0"
          sources."defer-to-connect-2.0.1"
          sources."get-stream-5.2.0"
          sources."got-11.8.5"
          sources."has-flag-4.0.0"
          sources."json-buffer-3.0.1"
          sources."jsonfile-4.0.0"
          sources."keyv-4.5.0"
          sources."lowercase-keys-2.0.0"
          sources."mimic-response-3.1.0"
          sources."normalize-url-6.1.0"
          sources."p-cancelable-2.1.1"
          sources."responselike-2.0.1"
          sources."supports-color-7.2.0"
          sources."universalify-0.1.2"
        ];
      })
      sources."@electron-forge/installer-base-6.0.0-beta.67"
      sources."@electron-forge/installer-darwin-6.0.0-beta.67"
      sources."@electron-forge/installer-deb-6.0.0-beta.67"
      sources."@electron-forge/installer-dmg-6.0.0-beta.67"
      sources."@electron-forge/installer-exe-6.0.0-beta.67"
      sources."@electron-forge/installer-linux-6.0.0-beta.67"
      sources."@electron-forge/installer-rpm-6.0.0-beta.67"
      sources."@electron-forge/installer-zip-6.0.0-beta.67"
      sources."@electron-forge/maker-base-6.0.0-beta.67"
      sources."@electron-forge/maker-deb-6.0.0-beta.67"
      sources."@electron-forge/maker-dmg-6.0.0-beta.67"
      (sources."@electron-forge/maker-flatpak-6.0.0-beta.67" // {
        dependencies = [
          sources."fs-extra-10.1.0"
        ];
      })
      sources."@electron-forge/maker-rpm-6.0.0-beta.67"
      sources."@electron-forge/maker-squirrel-6.0.0-beta.67"
      sources."@electron-forge/maker-zip-6.0.0-beta.67"
      sources."@electron-forge/plugin-base-6.0.0-beta.67"
      (sources."@electron-forge/plugin-webpack-6.0.0-beta.67" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."@electron-forge/publisher-base-6.0.0-beta.67"
      sources."@electron-forge/publisher-github-6.0.0-beta.67"
      sources."@electron-forge/shared-types-6.0.0-beta.67"
      sources."@electron-forge/template-base-6.0.0-beta.67"
      sources."@electron-forge/template-typescript-6.0.0-beta.67"
      sources."@electron-forge/template-typescript-webpack-6.0.0-beta.67"
      sources."@electron-forge/template-webpack-6.0.0-beta.67"
      sources."@electron-forge/web-multi-logger-6.0.0-beta.67"
      (sources."@electron/get-1.14.1" // {
        dependencies = [
          sources."fs-extra-8.1.0"
          sources."jsonfile-4.0.0"
          sources."semver-6.3.0"
          sources."universalify-0.1.2"
        ];
      })
      (sources."@electron/universal-1.3.1" // {
        dependencies = [
          sources."@malept/cross-spawn-promise-1.1.1"
          sources."fs-extra-9.1.0"
        ];
      })
      sources."@emotion/babel-plugin-11.7.2"
      sources."@emotion/cache-11.7.1"
      sources."@emotion/hash-0.8.0"
      sources."@emotion/is-prop-valid-1.1.2"
      sources."@emotion/memoize-0.7.5"
      sources."@emotion/react-11.9.0"
      sources."@emotion/serialize-1.0.3"
      sources."@emotion/sheet-1.1.0"
      sources."@emotion/styled-11.8.1"
      sources."@emotion/unitless-0.7.5"
      sources."@emotion/utils-1.1.0"
      sources."@emotion/weak-memoize-0.2.5"
      (sources."@eslint/eslintrc-1.3.0" // {
        dependencies = [
          sources."globals-13.15.0"
          sources."type-fest-0.20.2"
        ];
      })
      sources."@fontsource/open-sans-4.5.10"
      sources."@gar/promisify-1.1.3"
      sources."@humanwhocodes/config-array-0.9.5"
      sources."@humanwhocodes/object-schema-1.2.1"
      (sources."@istanbuljs/load-nyc-config-1.1.0" // {
        dependencies = [
          sources."argparse-1.0.10"
          sources."find-up-4.1.0"
          sources."js-yaml-3.14.1"
          sources."locate-path-5.0.0"
          sources."p-limit-2.3.0"
          sources."p-locate-4.1.0"
          sources."resolve-from-5.0.0"
        ];
      })
      sources."@istanbuljs/schema-0.1.3"
      (sources."@jest/console-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."@jest/core-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."ci-info-3.3.1"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          (sources."pretty-format-28.1.0" // {
            dependencies = [
              sources."ansi-styles-5.2.0"
            ];
          })
          sources."react-is-18.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."@jest/environment-28.1.0"
      sources."@jest/expect-28.1.0"
      sources."@jest/expect-utils-28.1.0"
      sources."@jest/fake-timers-28.1.0"
      sources."@jest/globals-28.1.0"
      (sources."@jest/reporters-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          (sources."jest-worker-28.1.0" // {
            dependencies = [
              sources."supports-color-8.1.1"
            ];
          })
          sources."supports-color-7.2.0"
        ];
      })
      sources."@jest/schemas-28.0.2"
      sources."@jest/source-map-28.0.2"
      sources."@jest/test-result-28.1.0"
      sources."@jest/test-sequencer-28.1.0"
      (sources."@jest/transform-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
          sources."write-file-atomic-4.0.1"
        ];
      })
      (sources."@jest/types-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."@jridgewell/gen-mapping-0.3.1"
      sources."@jridgewell/resolve-uri-3.0.5"
      sources."@jridgewell/set-array-1.1.1"
      sources."@jridgewell/source-map-0.3.2"
      sources."@jridgewell/sourcemap-codec-1.4.11"
      sources."@jridgewell/trace-mapping-0.3.13"
      sources."@malept/cross-spawn-promise-2.0.0"
      (sources."@malept/electron-installer-flatpak-0.11.4" // {
        dependencies = [
          sources."yargs-16.2.0"
        ];
      })
      (sources."@malept/flatpak-bundler-0.4.0" // {
        dependencies = [
          sources."fs-extra-9.1.0"
        ];
      })
      sources."@nodelib/fs.scandir-2.1.5"
      sources."@nodelib/fs.stat-2.0.5"
      sources."@nodelib/fs.walk-1.2.8"
      sources."@npmcli/fs-1.1.1"
      (sources."@npmcli/move-file-1.1.2" // {
        dependencies = [
          sources."mkdirp-1.0.4"
        ];
      })
      sources."@octokit/auth-token-2.5.0"
      sources."@octokit/core-3.5.1"
      sources."@octokit/endpoint-6.0.12"
      sources."@octokit/graphql-4.8.0"
      sources."@octokit/openapi-types-11.2.0"
      sources."@octokit/plugin-paginate-rest-2.17.0"
      sources."@octokit/plugin-request-log-1.0.4"
      sources."@octokit/plugin-rest-endpoint-methods-5.13.0"
      sources."@octokit/plugin-retry-3.0.9"
      sources."@octokit/request-5.6.3"
      sources."@octokit/request-error-2.1.0"
      sources."@octokit/rest-18.12.0"
      sources."@octokit/types-6.34.0"
      (sources."@pmmmwh/react-refresh-webpack-plugin-0.5.7" // {
        dependencies = [
          sources."schema-utils-3.1.1"
          sources."source-map-0.7.3"
        ];
      })
      sources."@popperjs/core-2.11.5"
      sources."@react-nano/use-event-source-0.12.0"
      sources."@reactflow/background-11.0.1"
      sources."@reactflow/controls-11.0.1"
      sources."@reactflow/core-11.1.0"
      sources."@reactflow/minimap-11.0.1"
      sources."@sinclair/typebox-0.23.5"
      sources."@sindresorhus/is-0.14.0"
      sources."@sinonjs/commons-1.8.3"
      sources."@sinonjs/fake-timers-9.1.2"
      sources."@szmarczak/http-timer-1.1.2"
      sources."@tootallnate/once-1.1.2"
      sources."@trysound/sax-0.2.0"
      sources."@tsconfig/node10-1.0.8"
      sources."@tsconfig/node12-1.0.9"
      sources."@tsconfig/node14-1.0.1"
      sources."@tsconfig/node16-1.0.2"
      sources."@types/babel__core-7.1.19"
      sources."@types/babel__generator-7.6.4"
      sources."@types/babel__template-7.4.1"
      sources."@types/babel__traverse-7.17.1"
      sources."@types/body-parser-1.19.2"
      sources."@types/bonjour-3.5.10"
      sources."@types/cacheable-request-6.0.2"
      sources."@types/connect-3.4.35"
      sources."@types/connect-history-api-fallback-1.3.5"
      sources."@types/d3-7.4.0"
      sources."@types/d3-array-3.0.2"
      sources."@types/d3-axis-3.0.1"
      sources."@types/d3-brush-3.0.1"
      sources."@types/d3-chord-3.0.1"
      sources."@types/d3-color-3.0.2"
      sources."@types/d3-contour-3.0.1"
      sources."@types/d3-delaunay-6.0.0"
      sources."@types/d3-dispatch-3.0.1"
      sources."@types/d3-drag-3.0.1"
      sources."@types/d3-dsv-3.0.0"
      sources."@types/d3-ease-3.0.0"
      sources."@types/d3-fetch-3.0.1"
      sources."@types/d3-force-3.0.3"
      sources."@types/d3-format-3.0.1"
      sources."@types/d3-geo-3.0.2"
      sources."@types/d3-hierarchy-3.0.2"
      sources."@types/d3-interpolate-3.0.1"
      sources."@types/d3-path-3.0.0"
      sources."@types/d3-polygon-3.0.0"
      sources."@types/d3-quadtree-3.0.2"
      sources."@types/d3-random-3.0.1"
      sources."@types/d3-scale-4.0.2"
      sources."@types/d3-scale-chromatic-3.0.0"
      sources."@types/d3-selection-3.0.3"
      sources."@types/d3-shape-3.0.2"
      sources."@types/d3-time-3.0.0"
      sources."@types/d3-time-format-4.0.0"
      sources."@types/d3-timer-3.0.0"
      sources."@types/d3-transition-3.0.1"
      sources."@types/d3-zoom-3.0.1"
      sources."@types/debug-4.1.7"
      sources."@types/decompress-4.2.4"
      sources."@types/eslint-8.4.1"
      sources."@types/eslint-scope-3.7.3"
      sources."@types/estree-0.0.51"
      sources."@types/events-3.0.0"
      sources."@types/express-4.17.13"
      sources."@types/express-serve-static-core-4.17.28"
      sources."@types/fs-extra-9.0.13"
      sources."@types/geojson-7946.0.8"
      sources."@types/glob-7.2.0"
      sources."@types/graceful-fs-4.1.5"
      sources."@types/hast-2.3.4"
      sources."@types/html-minifier-terser-6.1.0"
      sources."@types/http-cache-semantics-4.0.1"
      sources."@types/http-proxy-1.17.8"
      sources."@types/istanbul-lib-coverage-2.0.4"
      sources."@types/istanbul-lib-report-3.0.0"
      sources."@types/istanbul-reports-3.0.1"
      sources."@types/jest-28.1.0"
      sources."@types/json-buffer-3.0.0"
      sources."@types/json-schema-7.0.9"
      sources."@types/json5-0.0.29"
      sources."@types/keyv-3.1.4"
      sources."@types/lodash-4.14.182"
      sources."@types/lodash.mergewith-4.6.6"
      sources."@types/mdast-3.0.10"
      sources."@types/mdurl-1.0.2"
      sources."@types/mime-1.3.2"
      sources."@types/minimatch-3.0.5"
      sources."@types/minimist-1.2.2"
      sources."@types/ms-0.7.31"
      sources."@types/node-16.11.26"
      sources."@types/node-localstorage-1.3.0"
      sources."@types/normalize-package-data-2.4.1"
      sources."@types/os-utils-0.0.1"
      sources."@types/parse-json-4.0.0"
      sources."@types/prettier-2.6.1"
      sources."@types/prop-types-15.7.4"
      sources."@types/qs-6.9.7"
      sources."@types/range-parser-1.2.4"
      sources."@types/react-18.0.10"
      sources."@types/react-dom-18.0.5"
      sources."@types/responselike-1.0.0"
      sources."@types/retry-0.12.1"
      sources."@types/scheduler-0.16.2"
      sources."@types/semver-7.3.9"
      sources."@types/serve-index-1.9.1"
      sources."@types/serve-static-1.13.10"
      sources."@types/sockjs-0.3.33"
      sources."@types/stack-utils-2.0.1"
      sources."@types/unist-2.0.6"
      sources."@types/uuid-8.3.4"
      sources."@types/ws-8.5.2"
      sources."@types/yargs-17.0.10"
      sources."@types/yargs-parser-21.0.0"
      sources."@types/yauzl-2.10.0"
      sources."@typescript-eslint/eslint-plugin-5.27.0"
      sources."@typescript-eslint/parser-5.27.0"
      sources."@typescript-eslint/scope-manager-5.27.0"
      sources."@typescript-eslint/type-utils-5.27.0"
      sources."@typescript-eslint/types-5.27.0"
      (sources."@typescript-eslint/typescript-estree-5.27.0" // {
        dependencies = [
          sources."globby-11.1.0"
        ];
      })
      sources."@typescript-eslint/utils-5.27.0"
      (sources."@typescript-eslint/visitor-keys-5.27.0" // {
        dependencies = [
          sources."eslint-visitor-keys-3.3.0"
        ];
      })
      sources."@vercel/webpack-asset-relocator-loader-1.7.2"
      sources."@webassemblyjs/ast-1.11.1"
      sources."@webassemblyjs/floating-point-hex-parser-1.11.1"
      sources."@webassemblyjs/helper-api-error-1.11.1"
      sources."@webassemblyjs/helper-buffer-1.11.1"
      sources."@webassemblyjs/helper-numbers-1.11.1"
      sources."@webassemblyjs/helper-wasm-bytecode-1.11.1"
      sources."@webassemblyjs/helper-wasm-section-1.11.1"
      sources."@webassemblyjs/ieee754-1.11.1"
      sources."@webassemblyjs/leb128-1.11.1"
      sources."@webassemblyjs/utf8-1.11.1"
      sources."@webassemblyjs/wasm-edit-1.11.1"
      sources."@webassemblyjs/wasm-gen-1.11.1"
      sources."@webassemblyjs/wasm-opt-1.11.1"
      sources."@webassemblyjs/wasm-parser-1.11.1"
      sources."@webassemblyjs/wast-printer-1.11.1"
      sources."@xtuc/ieee754-1.2.0"
      sources."@xtuc/long-4.2.2"
      sources."abbrev-1.1.1"
      sources."accepts-1.3.8"
      sources."acorn-8.7.1"
      sources."acorn-jsx-5.3.2"
      sources."acorn-walk-8.2.0"
      sources."agent-base-6.0.2"
      sources."agentkeepalive-4.2.1"
      sources."aggregate-error-3.1.0"
      sources."ajv-6.12.6"
      (sources."ajv-formats-2.1.1" // {
        dependencies = [
          sources."ajv-8.10.0"
          sources."json-schema-traverse-1.0.0"
        ];
      })
      sources."ajv-keywords-3.5.2"
      sources."ansi-align-3.0.1"
      sources."ansi-escapes-4.3.2"
      sources."ansi-html-community-0.0.8"
      sources."ansi-regex-5.0.1"
      sources."ansi-styles-3.2.1"
      sources."antlr4-4.11.0"
      sources."anymatch-3.1.2"
      sources."appdmg-0.6.4"
      sources."aproba-2.0.0"
      sources."arch-2.2.0"
      (sources."archive-type-4.0.0" // {
        dependencies = [
          sources."file-type-4.4.0"
        ];
      })
      (sources."are-we-there-yet-3.0.0" // {
        dependencies = [
          sources."readable-stream-3.6.0"
        ];
      })
      sources."arg-4.1.3"
      sources."argparse-2.0.1"
      (sources."aria-hidden-1.1.3" // {
        dependencies = [
          sources."tslib-1.14.1"
        ];
      })
      sources."aria-query-4.2.2"
      sources."array-flatten-1.1.1"
      sources."array-includes-3.1.5"
      sources."array-union-2.1.0"
      sources."array.prototype.flat-1.2.5"
      sources."array.prototype.flatmap-1.3.0"
      sources."arrify-1.0.1"
      (sources."asar-3.1.0" // {
        dependencies = [
          sources."commander-5.1.0"
        ];
      })
      sources."ast-types-flow-0.0.7"
      sources."astral-regex-2.0.0"
      sources."async-1.5.2"
      sources."at-least-node-1.0.0"
      sources."author-regex-1.0.0"
      sources."axe-core-4.4.1"
      sources."axobject-query-2.2.0"
      (sources."babel-jest-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."babel-loader-8.2.5"
      sources."babel-plugin-istanbul-6.1.1"
      sources."babel-plugin-jest-hoist-28.0.2"
      sources."babel-plugin-macros-2.8.0"
      sources."babel-preset-current-node-syntax-1.0.1"
      sources."babel-preset-jest-28.0.2"
      sources."bail-2.0.2"
      sources."balanced-match-1.0.2"
      sources."base32-encode-1.2.0"
      sources."base64-js-1.5.1"
      sources."batch-0.6.1"
      sources."before-after-hook-2.2.2"
      sources."big.js-5.2.2"
      (sources."bin-build-3.0.0" // {
        dependencies = [
          sources."cross-spawn-5.1.0"
          sources."execa-0.7.0"
          sources."get-stream-3.0.0"
          sources."lru-cache-4.1.5"
          sources."shebang-command-1.2.0"
          sources."shebang-regex-1.0.0"
          sources."which-1.3.1"
          sources."yallist-2.1.2"
        ];
      })
      (sources."bin-check-4.1.0" // {
        dependencies = [
          sources."cross-spawn-5.1.0"
          sources."execa-0.7.0"
          sources."get-stream-3.0.0"
          sources."lru-cache-4.1.5"
          sources."shebang-command-1.2.0"
          sources."shebang-regex-1.0.0"
          sources."which-1.3.1"
          sources."yallist-2.1.2"
        ];
      })
      sources."bin-version-3.1.0"
      (sources."bin-version-check-4.0.0" // {
        dependencies = [
          sources."semver-5.7.1"
        ];
      })
      (sources."bin-wrapper-4.1.0" // {
        dependencies = [
          sources."@sindresorhus/is-0.7.0"
          sources."cacheable-request-2.1.4"
          (sources."download-7.1.0" // {
            dependencies = [
              sources."pify-3.0.0"
            ];
          })
          sources."file-type-8.1.0"
          sources."filenamify-2.1.0"
          sources."get-stream-3.0.0"
          (sources."got-8.3.2" // {
            dependencies = [
              sources."pify-3.0.0"
            ];
          })
          sources."http-cache-semantics-3.8.1"
          sources."keyv-3.0.0"
          sources."lowercase-keys-1.0.0"
          (sources."make-dir-1.3.0" // {
            dependencies = [
              sources."pify-3.0.0"
            ];
          })
          sources."normalize-url-2.0.1"
          sources."p-cancelable-0.4.1"
          sources."p-event-2.3.1"
          sources."p-timeout-2.0.1"
          sources."pify-4.0.1"
          sources."sort-keys-2.0.0"
        ];
      })
      sources."binary-extensions-2.2.0"
      (sources."bl-4.1.0" // {
        dependencies = [
          sources."readable-stream-3.6.0"
        ];
      })
      sources."bluebird-3.7.2"
      (sources."body-parser-1.19.2" // {
        dependencies = [
          sources."debug-2.6.9"
          sources."ms-2.0.0"
        ];
      })
      (sources."bonjour-3.5.0" // {
        dependencies = [
          sources."array-flatten-2.1.2"
        ];
      })
      sources."boolbase-1.0.0"
      sources."boolean-3.2.0"
      sources."bottleneck-2.19.5"
      (sources."boxen-5.1.2" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."camelcase-6.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
          sources."type-fest-0.20.2"
        ];
      })
      sources."bplist-creator-0.0.8"
      sources."brace-expansion-1.1.11"
      sources."braces-3.0.2"
      sources."browserslist-4.20.3"
      sources."bs-logger-0.2.6"
      sources."bser-2.1.1"
      sources."buffer-5.7.1"
      sources."buffer-alloc-1.2.0"
      sources."buffer-alloc-unsafe-1.1.0"
      sources."buffer-crc32-0.2.13"
      sources."buffer-equal-1.0.0"
      sources."buffer-fill-1.0.0"
      sources."buffer-from-1.1.2"
      sources."buffer-indexof-1.1.1"
      sources."bytes-3.1.2"
      (sources."cacache-15.3.0" // {
        dependencies = [
          sources."mkdirp-1.0.4"
        ];
      })
      sources."cacheable-lookup-5.0.4"
      (sources."cacheable-request-6.1.0" // {
        dependencies = [
          sources."get-stream-5.2.0"
          sources."lowercase-keys-2.0.0"
        ];
      })
      sources."call-bind-1.0.2"
      sources."callsites-3.1.0"
      sources."camel-case-4.1.2"
      sources."camelcase-5.3.1"
      (sources."camelcase-keys-6.2.2" // {
        dependencies = [
          sources."quick-lru-4.0.1"
        ];
      })
      sources."caniuse-lite-1.0.30001346"
      sources."caw-2.0.1"
      (sources."chalk-2.4.2" // {
        dependencies = [
          sources."escape-string-regexp-1.0.5"
        ];
      })
      sources."char-regex-1.0.2"
      sources."character-entities-2.0.1"
      sources."chardet-0.7.0"
      sources."chokidar-3.5.3"
      sources."chownr-2.0.0"
      sources."chrome-trace-event-1.0.3"
      sources."chromium-pickle-js-0.2.0"
      sources."ci-info-2.0.0"
      sources."cjs-module-lexer-1.2.2"
      sources."classcat-5.0.4"
      (sources."clean-css-5.2.4" // {
        dependencies = [
          sources."source-map-0.6.1"
        ];
      })
      sources."clean-stack-2.2.0"
      sources."cli-boxes-2.2.1"
      sources."cli-cursor-3.1.0"
      sources."cli-spinners-2.6.1"
      sources."cli-width-3.0.0"
      sources."cliui-7.0.4"
      sources."clone-1.0.4"
      (sources."clone-deep-4.0.1" // {
        dependencies = [
          sources."is-plain-object-2.0.4"
        ];
      })
      sources."clone-response-1.0.2"
      sources."co-4.6.0"
      sources."collect-v8-coverage-1.0.1"
      sources."color-convert-1.9.3"
      sources."color-name-1.1.3"
      sources."color-support-1.1.3"
      sources."colord-2.9.3"
      sources."colorette-2.0.16"
      sources."colors-1.0.3"
      sources."comma-separated-tokens-2.0.2"
      sources."commander-4.1.1"
      sources."common-path-prefix-3.0.0"
      sources."commondir-1.0.1"
      sources."compare-version-0.1.2"
      (sources."compress-brotli-1.3.8" // {
        dependencies = [
          sources."json-buffer-3.0.1"
        ];
      })
      sources."compressible-2.0.18"
      (sources."compression-1.7.4" // {
        dependencies = [
          sources."bytes-3.0.0"
          sources."debug-2.6.9"
          sources."ms-2.0.0"
        ];
      })
      sources."compute-scroll-into-view-1.0.14"
      sources."concat-map-0.0.1"
      (sources."concurrently-7.2.1" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          (sources."chalk-4.1.2" // {
            dependencies = [
              sources."supports-color-7.2.0"
            ];
          })
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-8.1.1"
        ];
      })
      sources."config-chain-1.1.13"
      (sources."configstore-5.0.1" // {
        dependencies = [
          sources."write-file-atomic-3.0.3"
        ];
      })
      sources."confusing-browser-globals-1.0.11"
      sources."connect-history-api-fallback-1.6.0"
      sources."console-control-strings-1.1.0"
      (sources."content-disposition-0.5.4" // {
        dependencies = [
          sources."safe-buffer-5.2.1"
        ];
      })
      sources."content-type-1.0.4"
      sources."convert-source-map-1.8.0"
      sources."cookie-0.4.2"
      sources."cookie-signature-1.0.6"
      sources."copy-to-clipboard-3.3.1"
      sources."core-js-pure-3.21.1"
      sources."core-util-is-1.0.3"
      sources."cosmiconfig-6.0.0"
      sources."create-require-1.1.1"
      sources."cross-env-7.0.3"
      sources."cross-fetch-3.1.5"
      sources."cross-spawn-7.0.3"
      (sources."cross-spawn-windows-exe-1.2.0" // {
        dependencies = [
          sources."@malept/cross-spawn-promise-1.1.1"
        ];
      })
      sources."cross-zip-4.0.0"
      sources."crypto-random-string-2.0.0"
      sources."css-box-model-1.2.1"
      sources."css-functions-list-3.1.0"
      sources."css-loader-6.7.1"
      sources."css-select-4.2.1"
      (sources."css-tree-1.1.3" // {
        dependencies = [
          sources."source-map-0.6.1"
        ];
      })
      sources."css-what-5.1.0"
      sources."cssesc-3.0.0"
      sources."csso-4.2.0"
      sources."csstype-3.0.11"
      sources."cuint-0.2.2"
      sources."cwebp-bin-7.0.1"
      sources."d3-color-3.1.0"
      sources."d3-dispatch-3.0.1"
      sources."d3-drag-3.0.0"
      sources."d3-ease-3.0.1"
      sources."d3-interpolate-3.0.1"
      sources."d3-selection-3.0.0"
      sources."d3-timer-3.0.1"
      sources."d3-transition-3.0.1"
      sources."d3-zoom-3.0.0"
      sources."damerau-levenshtein-1.0.8"
      sources."date-fns-2.28.0"
      sources."debug-4.3.4"
      sources."decamelize-1.2.0"
      (sources."decamelize-keys-1.1.0" // {
        dependencies = [
          sources."map-obj-1.0.1"
        ];
      })
      sources."decode-named-character-reference-1.0.1"
      sources."decode-uri-component-0.2.0"
      (sources."decompress-4.2.1" // {
        dependencies = [
          (sources."make-dir-1.3.0" // {
            dependencies = [
              sources."pify-3.0.0"
            ];
          })
        ];
      })
      sources."decompress-response-3.3.0"
      sources."decompress-tar-4.1.1"
      (sources."decompress-tarbz2-4.1.1" // {
        dependencies = [
          sources."file-type-6.2.0"
        ];
      })
      sources."decompress-targz-4.1.1"
      (sources."decompress-unzip-4.0.1" // {
        dependencies = [
          sources."file-type-3.9.0"
        ];
      })
      sources."dedent-0.7.0"
      sources."deep-equal-1.1.1"
      sources."deep-extend-0.6.0"
      sources."deep-is-0.1.4"
      sources."deepmerge-4.2.2"
      (sources."default-gateway-6.0.3" // {
        dependencies = [
          sources."execa-5.1.1"
          sources."get-stream-6.0.1"
          sources."is-stream-2.0.1"
          sources."npm-run-path-4.0.1"
        ];
      })
      sources."defaults-1.0.3"
      sources."defer-to-connect-1.1.3"
      sources."define-lazy-prop-2.0.0"
      sources."define-properties-1.1.4"
      (sources."del-6.0.0" // {
        dependencies = [
          sources."globby-11.1.0"
        ];
      })
      sources."delegates-1.0.0"
      sources."depd-1.1.2"
      sources."deprecation-2.3.1"
      sources."dequal-2.0.2"
      sources."destroy-1.0.4"
      sources."detect-libc-1.0.3"
      sources."detect-newline-3.1.0"
      sources."detect-node-2.1.0"
      sources."detect-node-es-1.1.0"
      sources."diff-5.0.0"
      sources."diff-sequences-27.5.1"
      (sources."dir-compare-2.4.0" // {
        dependencies = [
          sources."commander-2.9.0"
          sources."minimatch-3.0.4"
        ];
      })
      sources."dir-glob-3.0.1"
      sources."dns-equal-1.0.0"
      sources."dns-packet-1.3.4"
      sources."dns-txt-2.0.2"
      sources."doctrine-3.0.0"
      sources."dom-converter-0.2.0"
      sources."dom-serializer-1.3.2"
      sources."dom-walk-0.1.2"
      sources."domelementtype-2.2.0"
      sources."domhandler-4.3.0"
      sources."domutils-2.8.0"
      sources."dot-case-3.0.4"
      sources."dot-prop-5.3.0"
      (sources."download-6.2.5" // {
        dependencies = [
          sources."filenamify-2.1.0"
          sources."get-stream-3.0.0"
          sources."got-7.1.0"
          sources."make-dir-1.3.0"
          sources."p-cancelable-0.3.0"
          sources."pify-3.0.0"
          sources."prepend-http-1.0.4"
          sources."url-parse-lax-1.0.0"
        ];
      })
      sources."ds-store-0.1.6"
      sources."duplexer3-0.1.4"
      sources."ee-first-1.1.1"
      sources."electron-20.1.4"
      (sources."electron-installer-common-0.10.3" // {
        dependencies = [
          sources."@malept/cross-spawn-promise-1.1.1"
          sources."fs-extra-9.1.0"
        ];
      })
      (sources."electron-installer-debian-3.1.0" // {
        dependencies = [
          sources."@malept/cross-spawn-promise-1.1.1"
          sources."ansi-styles-4.3.0"
          sources."cliui-6.0.0"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."find-up-4.1.0"
          sources."fs-extra-9.1.0"
          sources."locate-path-5.0.0"
          sources."p-limit-2.3.0"
          sources."p-locate-4.1.0"
          sources."wrap-ansi-6.2.0"
          sources."y18n-4.0.3"
          sources."yargs-15.4.1"
          sources."yargs-parser-18.1.3"
        ];
      })
      sources."electron-installer-dmg-4.0.0"
      (sources."electron-installer-redhat-3.3.0" // {
        dependencies = [
          sources."@malept/cross-spawn-promise-1.1.1"
          sources."fs-extra-9.1.0"
          sources."yargs-16.2.0"
        ];
      })
      sources."electron-log-4.4.8"
      (sources."electron-notarize-1.2.1" // {
        dependencies = [
          sources."fs-extra-9.1.0"
        ];
      })
      (sources."electron-osx-sign-0.5.0" // {
        dependencies = [
          sources."debug-2.6.9"
          sources."ms-2.0.0"
        ];
      })
      (sources."electron-packager-16.0.0" // {
        dependencies = [
          (sources."@electron/get-2.0.1" // {
            dependencies = [
              sources."fs-extra-8.1.0"
              sources."jsonfile-4.0.0"
              sources."semver-6.3.0"
              sources."universalify-0.1.2"
            ];
          })
          sources."@sindresorhus/is-4.6.0"
          sources."@szmarczak/http-timer-4.0.6"
          sources."cacheable-request-7.0.2"
          sources."decompress-response-6.0.0"
          sources."defer-to-connect-2.0.1"
          sources."fs-extra-10.1.0"
          sources."get-stream-5.2.0"
          sources."got-11.8.5"
          sources."json-buffer-3.0.1"
          sources."keyv-4.5.0"
          sources."lowercase-keys-2.0.0"
          sources."mimic-response-3.1.0"
          sources."normalize-url-6.1.0"
          sources."p-cancelable-2.1.1"
          sources."responselike-2.0.1"
          sources."yargs-parser-21.1.1"
        ];
      })
      (sources."electron-rebuild-3.2.7" // {
        dependencies = [
          sources."@sindresorhus/is-4.6.0"
          sources."@szmarczak/http-timer-4.0.6"
          sources."ansi-styles-4.3.0"
          sources."cacheable-request-7.0.2"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."decompress-response-6.0.0"
          sources."defer-to-connect-2.0.1"
          sources."get-stream-5.2.0"
          sources."got-11.8.5"
          sources."has-flag-4.0.0"
          sources."json-buffer-3.0.1"
          sources."keyv-4.3.2"
          sources."lowercase-keys-2.0.0"
          sources."mimic-response-3.1.0"
          sources."normalize-url-6.1.0"
          sources."p-cancelable-2.1.1"
          sources."responselike-2.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."electron-squirrel-startup-1.0.0" // {
        dependencies = [
          sources."debug-2.6.9"
          sources."ms-2.0.0"
        ];
      })
      sources."electron-to-chromium-1.4.144"
      (sources."electron-winstaller-5.0.0" // {
        dependencies = [
          sources."asar-2.1.0"
          sources."commander-2.20.3"
          sources."fs-extra-7.0.1"
          sources."jsonfile-4.0.0"
          sources."rimraf-2.7.1"
          sources."tmp-0.1.0"
          sources."tmp-promise-1.1.0"
          sources."universalify-0.1.2"
        ];
      })
      sources."emittery-0.10.2"
      sources."emoji-regex-9.2.2"
      sources."emojis-list-3.0.0"
      sources."encode-utf8-1.0.3"
      sources."encodeurl-1.0.2"
      (sources."encoding-0.1.13" // {
        dependencies = [
          sources."iconv-lite-0.6.3"
        ];
      })
      sources."end-of-stream-1.4.4"
      sources."enhanced-resolve-5.9.2"
      sources."entities-2.2.0"
      sources."env-paths-2.2.1"
      sources."err-code-2.0.3"
      sources."error-ex-1.3.2"
      sources."error-stack-parser-2.0.7"
      sources."es-abstract-1.20.1"
      sources."es-module-lexer-0.9.3"
      sources."es-shim-unscopables-1.0.0"
      sources."es-to-primitive-1.2.1"
      sources."es6-error-4.1.1"
      sources."escalade-3.1.1"
      sources."escape-goat-2.1.1"
      sources."escape-html-1.0.3"
      sources."escape-string-regexp-4.0.0"
      (sources."eslint-8.16.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."eslint-scope-7.1.1"
          sources."eslint-visitor-keys-3.3.0"
          sources."glob-parent-6.0.2"
          sources."globals-13.15.0"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
          sources."type-fest-0.20.2"
        ];
      })
      sources."eslint-config-airbnb-19.0.4"
      (sources."eslint-config-airbnb-base-15.0.0" // {
        dependencies = [
          sources."semver-6.3.0"
        ];
      })
      sources."eslint-config-airbnb-typescript-17.0.0"
      sources."eslint-config-prettier-8.5.0"
      (sources."eslint-import-resolver-node-0.3.6" // {
        dependencies = [
          sources."debug-3.2.7"
        ];
      })
      sources."eslint-import-resolver-typescript-2.7.1"
      (sources."eslint-module-utils-2.7.3" // {
        dependencies = [
          sources."debug-3.2.7"
          sources."find-up-2.1.0"
          sources."locate-path-2.0.0"
          sources."p-limit-1.3.0"
          sources."p-locate-2.0.0"
          sources."p-try-1.0.0"
          sources."path-exists-3.0.0"
        ];
      })
      (sources."eslint-plugin-eslint-comments-3.2.0" // {
        dependencies = [
          sources."escape-string-regexp-1.0.5"
        ];
      })
      (sources."eslint-plugin-import-2.25.4" // {
        dependencies = [
          sources."debug-2.6.9"
          sources."doctrine-2.1.0"
          sources."ms-2.0.0"
        ];
      })
      sources."eslint-plugin-jsx-a11y-6.5.1"
      sources."eslint-plugin-prefer-arrow-functions-3.1.4"
      sources."eslint-plugin-prettier-4.0.0"
      (sources."eslint-plugin-react-7.30.0" // {
        dependencies = [
          sources."doctrine-2.1.0"
          sources."resolve-2.0.0-next.3"
          sources."semver-6.3.0"
        ];
      })
      sources."eslint-plugin-react-hooks-4.6.0"
      sources."eslint-plugin-react-memo-0.0.3"
      sources."eslint-plugin-unused-imports-2.0.0"
      sources."eslint-rule-composer-0.3.0"
      (sources."eslint-scope-5.1.1" // {
        dependencies = [
          sources."estraverse-4.3.0"
        ];
      })
      sources."eslint-utils-3.0.0"
      sources."eslint-visitor-keys-2.1.0"
      (sources."espree-9.3.2" // {
        dependencies = [
          sources."eslint-visitor-keys-3.3.0"
        ];
      })
      sources."esprima-4.0.1"
      sources."esquery-1.4.0"
      sources."esrecurse-4.3.0"
      sources."estraverse-5.3.0"
      sources."esutils-2.0.3"
      sources."etag-1.8.1"
      sources."eventemitter3-4.0.7"
      sources."events-3.3.0"
      (sources."exec-buffer-3.2.0" // {
        dependencies = [
          sources."cross-spawn-5.1.0"
          sources."execa-0.7.0"
          sources."get-stream-3.0.0"
          sources."lru-cache-4.1.5"
          sources."pify-3.0.0"
          sources."rimraf-2.7.1"
          sources."shebang-command-1.2.0"
          sources."shebang-regex-1.0.0"
          sources."which-1.3.1"
          sources."yallist-2.1.2"
        ];
      })
      (sources."execa-1.0.0" // {
        dependencies = [
          sources."cross-spawn-6.0.5"
          sources."get-stream-4.1.0"
          sources."path-key-2.0.1"
          sources."semver-5.7.1"
          sources."shebang-command-1.2.0"
          sources."shebang-regex-1.0.0"
          sources."which-1.3.1"
        ];
      })
      sources."executable-4.1.1"
      sources."exit-0.1.2"
      sources."expand-tilde-2.0.2"
      (sources."expect-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."diff-sequences-28.0.2"
          sources."has-flag-4.0.0"
          sources."jest-diff-28.1.0"
          sources."jest-matcher-utils-28.1.0"
          (sources."pretty-format-28.1.0" // {
            dependencies = [
              sources."ansi-styles-5.2.0"
            ];
          })
          sources."react-is-18.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."express-4.17.3" // {
        dependencies = [
          sources."debug-2.6.9"
          sources."ms-2.0.0"
          sources."safe-buffer-5.2.1"
        ];
      })
      sources."express-ws-5.0.2"
      sources."ext-list-2.2.2"
      sources."ext-name-5.0.0"
      sources."extend-3.0.2"
      sources."external-editor-3.1.0"
      (sources."extract-zip-2.0.1" // {
        dependencies = [
          sources."get-stream-5.2.0"
        ];
      })
      sources."fast-deep-equal-3.1.3"
      sources."fast-diff-1.2.0"
      sources."fast-glob-3.2.12"
      sources."fast-json-stable-stringify-2.1.0"
      sources."fast-levenshtein-2.0.6"
      sources."fast-xml-parser-3.21.1"
      sources."fastest-levenshtein-1.0.16"
      sources."fastq-1.13.0"
      sources."faye-websocket-0.11.4"
      sources."fb-watchman-2.0.1"
      sources."fd-slicer-1.1.0"
      (sources."figures-3.2.0" // {
        dependencies = [
          sources."escape-string-regexp-1.0.5"
        ];
      })
      sources."file-entry-cache-6.0.1"
      (sources."file-loader-6.2.0" // {
        dependencies = [
          sources."schema-utils-3.1.1"
        ];
      })
      sources."file-type-5.2.0"
      sources."filename-reserved-regex-2.0.0"
      sources."filenamify-4.3.0"
      sources."fill-range-7.0.1"
      (sources."finalhandler-1.1.2" // {
        dependencies = [
          sources."debug-2.6.9"
          sources."ms-2.0.0"
        ];
      })
      sources."find-cache-dir-3.3.2"
      sources."find-root-1.1.0"
      sources."find-up-5.0.0"
      (sources."find-versions-3.2.0" // {
        dependencies = [
          sources."semver-regex-2.0.0"
        ];
      })
      sources."flat-cache-3.0.4"
      sources."flatted-3.2.5"
      (sources."flora-colossus-1.0.1" // {
        dependencies = [
          sources."fs-extra-7.0.1"
          sources."jsonfile-4.0.0"
          sources."universalify-0.1.2"
        ];
      })
      sources."fmix-0.1.0"
      sources."focus-lock-0.11.2"
      sources."follow-redirects-1.14.9"
      sources."forwarded-0.2.0"
      (sources."framer-motion-6.3.6" // {
        dependencies = [
          sources."@emotion/is-prop-valid-0.8.8"
          sources."@emotion/memoize-0.7.4"
          sources."framesync-6.0.1"
        ];
      })
      sources."framesync-5.3.0"
      sources."fresh-0.5.2"
      sources."from2-2.3.0"
      sources."fs-constants-1.0.0"
      sources."fs-extra-10.0.1"
      sources."fs-minipass-2.1.0"
      sources."fs-monkey-1.0.3"
      sources."fs-temp-1.2.1"
      sources."fs-xattr-0.3.1"
      sources."fs.realpath-1.0.0"
      sources."fsevents-2.3.2"
      sources."function-bind-1.1.1"
      sources."function.prototype.name-1.1.5"
      sources."functional-red-black-tree-1.0.1"
      sources."functions-have-names-1.2.3"
      (sources."galactus-0.2.1" // {
        dependencies = [
          sources."debug-3.2.7"
          sources."fs-extra-4.0.3"
          sources."jsonfile-4.0.0"
          sources."universalify-0.1.2"
        ];
      })
      sources."gar-1.0.4"
      sources."gauge-4.0.4"
      sources."generate-function-2.3.1"
      sources."generate-object-property-1.2.0"
      sources."gensync-1.0.0-beta.2"
      sources."get-caller-file-2.0.5"
      sources."get-folder-size-2.0.1"
      sources."get-installed-path-2.1.1"
      sources."get-intrinsic-1.1.1"
      sources."get-nonce-1.0.1"
      (sources."get-package-info-1.0.0" // {
        dependencies = [
          sources."debug-2.6.9"
          sources."ms-2.0.0"
        ];
      })
      sources."get-package-type-0.1.0"
      sources."get-proxy-2.1.0"
      sources."get-stream-2.3.1"
      sources."get-symbol-description-1.0.0"
      (sources."gifsicle-5.3.0" // {
        dependencies = [
          sources."execa-5.1.1"
          sources."get-stream-6.0.1"
          sources."is-stream-2.0.1"
          sources."npm-run-path-4.0.1"
        ];
      })
      sources."glob-7.2.0"
      sources."glob-parent-5.1.2"
      sources."glob-to-regexp-0.4.1"
      sources."global-4.4.0"
      sources."global-agent-3.0.0"
      (sources."global-dirs-3.0.0" // {
        dependencies = [
          sources."ini-2.0.0"
        ];
      })
      sources."global-modules-1.0.0"
      (sources."global-prefix-1.0.2" // {
        dependencies = [
          sources."which-1.3.1"
        ];
      })
      sources."global-tunnel-ng-2.7.1"
      sources."globals-11.12.0"
      sources."globalthis-1.0.2"
      sources."globby-10.0.2"
      sources."globjoin-0.1.4"
      (sources."got-9.6.0" // {
        dependencies = [
          sources."get-stream-4.1.0"
        ];
      })
      sources."graceful-fs-4.2.9"
      sources."graceful-readlink-1.0.1"
      sources."handle-thing-2.0.1"
      sources."hard-rejection-2.1.0"
      sources."has-1.0.3"
      sources."has-bigints-1.0.2"
      sources."has-flag-3.0.0"
      sources."has-property-descriptors-1.0.0"
      sources."has-symbol-support-x-1.4.2"
      sources."has-symbols-1.0.3"
      sources."has-to-string-tag-x-1.4.1"
      sources."has-tostringtag-1.0.0"
      sources."has-unicode-2.0.1"
      sources."has-yarn-2.1.0"
      sources."hast-util-whitespace-2.0.0"
      sources."he-1.2.0"
      sources."hey-listen-1.0.8"
      sources."hoist-non-react-statics-3.3.2"
      sources."homedir-polyfill-1.0.3"
      sources."hosted-git-info-2.8.9"
      sources."hotkeys-js-3.9.3"
      sources."hpack.js-2.1.6"
      sources."html-entities-2.3.2"
      sources."html-escaper-2.0.2"
      (sources."html-minifier-terser-6.1.0" // {
        dependencies = [
          sources."commander-8.3.0"
        ];
      })
      sources."html-tags-3.2.0"
      sources."html-webpack-plugin-5.5.0"
      sources."htmlparser2-6.1.0"
      sources."http-cache-semantics-4.1.0"
      sources."http-deceiver-1.2.7"
      sources."http-errors-1.8.1"
      sources."http-parser-js-0.5.6"
      sources."http-proxy-1.18.1"
      sources."http-proxy-agent-4.0.1"
      (sources."http-proxy-middleware-2.0.3" // {
        dependencies = [
          sources."is-plain-obj-3.0.0"
        ];
      })
      sources."http2-wrapper-1.0.3"
      sources."https-proxy-agent-5.0.0"
      sources."human-signals-2.1.0"
      sources."humanize-ms-1.2.1"
      sources."iconv-lite-0.4.24"
      sources."icss-utils-5.1.0"
      sources."ieee754-1.2.1"
      sources."ignore-5.2.0"
      sources."ignore-by-default-1.0.1"
      sources."image-size-0.7.5"
      sources."image-webpack-loader-8.1.0"
      (sources."imagemin-7.0.1" // {
        dependencies = [
          sources."file-type-12.4.2"
        ];
      })
      sources."imagemin-gifsicle-7.0.0"
      (sources."imagemin-mozjpeg-9.0.0" // {
        dependencies = [
          sources."execa-4.1.0"
          sources."get-stream-5.2.0"
          sources."human-signals-1.1.1"
          sources."is-stream-2.0.1"
          sources."npm-run-path-4.0.1"
        ];
      })
      sources."imagemin-optipng-8.0.0"
      (sources."imagemin-pngquant-9.0.2" // {
        dependencies = [
          sources."execa-4.1.0"
          sources."get-stream-5.2.0"
          sources."human-signals-1.1.1"
          sources."is-stream-2.0.1"
          sources."npm-run-path-4.0.1"
        ];
      })
      sources."imagemin-svgo-9.0.0"
      sources."imagemin-webp-7.0.0"
      sources."immutable-4.1.0"
      sources."import-fresh-3.3.0"
      sources."import-lazy-3.1.0"
      sources."import-local-3.1.0"
      sources."imul-1.0.1"
      sources."imurmurhash-0.1.4"
      sources."indent-string-4.0.0"
      sources."infer-owner-1.0.4"
      sources."inflight-1.0.6"
      sources."inherits-2.0.4"
      sources."ini-1.3.8"
      sources."inline-style-parser-0.1.1"
      (sources."inquirer-8.2.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."rxjs-7.5.4"
          sources."supports-color-7.2.0"
        ];
      })
      sources."internal-slot-1.0.3"
      (sources."into-stream-3.1.0" // {
        dependencies = [
          sources."p-is-promise-1.1.0"
        ];
      })
      sources."invariant-2.2.4"
      sources."ip-1.1.5"
      sources."ipaddr.js-1.9.1"
      sources."is-arguments-1.1.1"
      sources."is-arrayish-0.2.1"
      sources."is-bigint-1.0.4"
      sources."is-binary-path-2.1.0"
      sources."is-boolean-object-1.1.2"
      sources."is-buffer-2.0.5"
      sources."is-callable-1.2.4"
      sources."is-ci-2.0.0"
      sources."is-core-module-2.8.1"
      (sources."is-cwebp-readable-3.0.0" // {
        dependencies = [
          sources."file-type-10.11.0"
        ];
      })
      sources."is-date-object-1.0.5"
      sources."is-docker-2.2.1"
      sources."is-extglob-2.1.1"
      sources."is-fullwidth-code-point-3.0.0"
      sources."is-generator-fn-2.1.0"
      (sources."is-gif-3.0.0" // {
        dependencies = [
          sources."file-type-10.11.0"
        ];
      })
      sources."is-glob-4.0.3"
      sources."is-installed-globally-0.4.0"
      sources."is-interactive-1.0.0"
      sources."is-jpg-2.0.0"
      sources."is-lambda-1.0.1"
      sources."is-my-ip-valid-1.0.1"
      sources."is-my-json-valid-2.20.6"
      sources."is-natural-number-4.0.1"
      sources."is-negative-zero-2.0.2"
      sources."is-npm-5.0.0"
      sources."is-number-7.0.0"
      sources."is-number-object-1.0.7"
      sources."is-obj-2.0.0"
      sources."is-object-1.0.2"
      sources."is-path-cwd-2.2.0"
      sources."is-path-inside-3.0.3"
      sources."is-plain-obj-1.1.0"
      sources."is-plain-object-5.0.0"
      sources."is-png-2.0.0"
      sources."is-property-1.0.2"
      sources."is-regex-1.1.4"
      sources."is-retry-allowed-1.2.0"
      sources."is-shared-array-buffer-1.0.2"
      sources."is-stream-1.1.0"
      sources."is-string-1.0.7"
      sources."is-svg-4.3.2"
      sources."is-symbol-1.0.4"
      sources."is-typedarray-1.0.0"
      sources."is-unicode-supported-0.1.0"
      sources."is-weakref-1.0.2"
      sources."is-windows-1.0.2"
      sources."is-wsl-2.2.0"
      sources."is-yarn-global-0.3.0"
      sources."isarray-1.0.0"
      sources."isbinaryfile-3.0.3"
      sources."isexe-2.0.0"
      sources."isobject-3.0.1"
      sources."istanbul-lib-coverage-3.2.0"
      (sources."istanbul-lib-instrument-5.2.0" // {
        dependencies = [
          sources."semver-6.3.0"
        ];
      })
      (sources."istanbul-lib-report-3.0.0" // {
        dependencies = [
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."istanbul-lib-source-maps-4.0.1" // {
        dependencies = [
          sources."source-map-0.6.1"
        ];
      })
      sources."istanbul-reports-3.1.4"
      sources."isurl-1.0.0"
      sources."jest-28.1.0"
      (sources."jest-changed-files-28.0.2" // {
        dependencies = [
          sources."execa-5.1.1"
          sources."get-stream-6.0.1"
          sources."is-stream-2.0.1"
          sources."npm-run-path-4.0.1"
        ];
      })
      (sources."jest-circus-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."diff-sequences-28.0.2"
          sources."has-flag-4.0.0"
          sources."jest-diff-28.1.0"
          sources."jest-matcher-utils-28.1.0"
          (sources."pretty-format-28.1.0" // {
            dependencies = [
              sources."ansi-styles-5.2.0"
            ];
          })
          sources."react-is-18.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-cli-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-config-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."ci-info-3.3.1"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          (sources."pretty-format-28.1.0" // {
            dependencies = [
              sources."ansi-styles-5.2.0"
            ];
          })
          sources."react-is-18.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-diff-27.5.1" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."jest-get-type-27.5.1"
          sources."supports-color-7.2.0"
        ];
      })
      sources."jest-docblock-28.0.2"
      (sources."jest-each-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          (sources."pretty-format-28.1.0" // {
            dependencies = [
              sources."ansi-styles-5.2.0"
            ];
          })
          sources."react-is-18.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."jest-environment-node-28.1.0"
      sources."jest-get-type-28.0.2"
      (sources."jest-haste-map-28.1.0" // {
        dependencies = [
          sources."has-flag-4.0.0"
          sources."jest-worker-28.1.0"
          sources."supports-color-8.1.1"
        ];
      })
      (sources."jest-leak-detector-28.1.0" // {
        dependencies = [
          sources."ansi-styles-5.2.0"
          sources."pretty-format-28.1.0"
          sources."react-is-18.1.0"
        ];
      })
      (sources."jest-matcher-utils-27.5.1" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."jest-get-type-27.5.1"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-message-util-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          (sources."pretty-format-28.1.0" // {
            dependencies = [
              sources."ansi-styles-5.2.0"
            ];
          })
          sources."react-is-18.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."jest-mock-28.1.0"
      sources."jest-pnp-resolver-1.2.2"
      sources."jest-regex-util-28.0.2"
      (sources."jest-resolve-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."jest-resolve-dependencies-28.1.0"
      (sources."jest-runner-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          (sources."jest-worker-28.1.0" // {
            dependencies = [
              sources."supports-color-8.1.1"
            ];
          })
          sources."source-map-0.6.1"
          sources."source-map-support-0.5.13"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-runtime-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."execa-5.1.1"
          sources."get-stream-6.0.1"
          sources."has-flag-4.0.0"
          sources."is-stream-2.0.1"
          sources."npm-run-path-4.0.1"
          sources."strip-bom-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-snapshot-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."diff-sequences-28.0.2"
          sources."has-flag-4.0.0"
          sources."jest-diff-28.1.0"
          sources."jest-matcher-utils-28.1.0"
          (sources."pretty-format-28.1.0" // {
            dependencies = [
              sources."ansi-styles-5.2.0"
            ];
          })
          sources."react-is-18.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-util-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."ci-info-3.3.1"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-validate-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."camelcase-6.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          (sources."pretty-format-28.1.0" // {
            dependencies = [
              sources."ansi-styles-5.2.0"
            ];
          })
          sources."react-is-18.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-watcher-28.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      (sources."jest-worker-27.5.1" // {
        dependencies = [
          sources."has-flag-4.0.0"
          sources."supports-color-8.1.1"
        ];
      })
      sources."js-tokens-4.0.0"
      sources."js-yaml-4.1.0"
      sources."jsesc-2.5.2"
      sources."json-buffer-3.0.0"
      sources."json-parse-better-errors-1.0.2"
      sources."json-parse-even-better-errors-2.3.1"
      sources."json-schema-traverse-0.4.1"
      sources."json-stable-stringify-without-jsonify-1.0.1"
      sources."json-stringify-safe-5.0.1"
      sources."json5-2.2.1"
      sources."jsonfile-6.1.0"
      sources."jsonpointer-5.0.0"
      sources."jsx-ast-utils-3.2.1"
      sources."junk-3.1.0"
      sources."keyv-3.1.0"
      sources."kind-of-6.0.3"
      sources."kleur-4.1.4"
      sources."klona-2.0.5"
      sources."known-css-properties-0.25.0"
      sources."language-subtag-registry-0.3.21"
      sources."language-tags-1.0.5"
      sources."latest-version-5.1.0"
      sources."leven-3.1.0"
      sources."levn-0.4.1"
      sources."lines-and-columns-1.2.4"
      (sources."load-json-file-2.0.0" // {
        dependencies = [
          sources."parse-json-2.2.0"
        ];
      })
      sources."loader-runner-4.2.0"
      sources."loader-utils-2.0.2"
      sources."locate-path-6.0.0"
      sources."lodash-4.17.21"
      sources."lodash._reinterpolate-3.0.0"
      sources."lodash.get-4.4.2"
      sources."lodash.memoize-4.1.2"
      sources."lodash.merge-4.6.2"
      sources."lodash.mergewith-4.6.2"
      sources."lodash.template-4.5.0"
      sources."lodash.templatesettings-4.2.0"
      sources."lodash.truncate-4.4.2"
      (sources."log-symbols-4.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."loose-envify-1.4.0"
      sources."lower-case-2.0.2"
      sources."lowercase-keys-1.0.1"
      sources."lru-cache-6.0.0"
      (sources."lzma-native-8.0.6" // {
        dependencies = [
          sources."readable-stream-3.6.0"
        ];
      })
      sources."macos-alias-0.2.11"
      (sources."make-dir-3.1.0" // {
        dependencies = [
          sources."semver-6.3.0"
        ];
      })
      sources."make-error-1.3.6"
      sources."make-fetch-happen-9.1.0"
      sources."makeerror-1.0.12"
      sources."map-age-cleaner-0.1.3"
      sources."map-obj-4.3.0"
      sources."matcher-3.0.0"
      sources."mathml-tag-names-2.1.3"
      (sources."mdast-util-definitions-5.1.0" // {
        dependencies = [
          sources."unist-util-visit-3.1.0"
          sources."unist-util-visit-parents-4.1.1"
        ];
      })
      sources."mdast-util-from-markdown-1.2.0"
      sources."mdast-util-to-hast-12.1.1"
      sources."mdast-util-to-string-3.1.0"
      sources."mdn-data-2.0.14"
      sources."mdurl-1.0.1"
      sources."media-typer-0.3.0"
      sources."mem-4.3.0"
      sources."memfs-3.4.1"
      (sources."meow-9.0.0" // {
        dependencies = [
          sources."find-up-4.1.0"
          sources."hosted-git-info-4.1.0"
          sources."locate-path-5.0.0"
          sources."normalize-package-data-3.0.3"
          sources."p-limit-2.3.0"
          sources."p-locate-4.1.0"
          (sources."read-pkg-5.2.0" // {
            dependencies = [
              sources."hosted-git-info-2.8.9"
              sources."normalize-package-data-2.5.0"
              sources."semver-5.7.1"
              sources."type-fest-0.6.0"
            ];
          })
          (sources."read-pkg-up-7.0.1" // {
            dependencies = [
              sources."type-fest-0.8.1"
            ];
          })
          sources."type-fest-0.18.1"
        ];
      })
      sources."merge-descriptors-1.0.1"
      sources."merge-stream-2.0.0"
      sources."merge2-1.4.1"
      sources."methods-1.1.2"
      sources."micromark-3.0.10"
      sources."micromark-core-commonmark-1.0.6"
      sources."micromark-factory-destination-1.0.0"
      sources."micromark-factory-label-1.0.2"
      sources."micromark-factory-space-1.0.0"
      sources."micromark-factory-title-1.0.2"
      sources."micromark-factory-whitespace-1.0.0"
      sources."micromark-util-character-1.1.0"
      sources."micromark-util-chunked-1.0.0"
      sources."micromark-util-classify-character-1.0.0"
      sources."micromark-util-combine-extensions-1.0.0"
      sources."micromark-util-decode-numeric-character-reference-1.0.0"
      sources."micromark-util-decode-string-1.0.2"
      sources."micromark-util-encode-1.0.1"
      sources."micromark-util-html-tag-name-1.0.0"
      sources."micromark-util-normalize-identifier-1.0.0"
      sources."micromark-util-resolve-all-1.0.0"
      sources."micromark-util-sanitize-uri-1.0.0"
      sources."micromark-util-subtokenize-1.0.2"
      sources."micromark-util-symbol-1.0.1"
      sources."micromark-util-types-1.0.2"
      sources."micromatch-4.0.5"
      sources."mime-1.6.0"
      sources."mime-db-1.52.0"
      (sources."mime-types-2.1.34" // {
        dependencies = [
          sources."mime-db-1.51.0"
        ];
      })
      sources."mimic-fn-2.1.0"
      sources."mimic-response-1.0.1"
      sources."min-document-2.19.0"
      sources."min-indent-1.0.1"
      sources."minimalistic-assert-1.0.1"
      sources."minimatch-3.1.2"
      sources."minimist-1.2.6"
      sources."minimist-options-4.1.0"
      sources."minipass-3.3.4"
      sources."minipass-collect-1.0.2"
      sources."minipass-fetch-1.4.1"
      sources."minipass-flush-1.0.5"
      sources."minipass-pipeline-1.2.4"
      sources."minipass-sized-1.0.3"
      sources."minizlib-2.1.2"
      sources."mkdirp-0.5.6"
      sources."mozjpeg-7.1.1"
      sources."mri-1.2.0"
      sources."ms-2.1.2"
      sources."multicast-dns-6.2.3"
      sources."multicast-dns-service-types-1.1.0"
      sources."murmur-32-0.2.0"
      sources."mute-stream-0.0.8"
      sources."nan-2.16.0"
      sources."nanoid-3.3.4"
      sources."natural-compare-1.4.0"
      sources."negotiator-0.6.3"
      sources."neo-async-2.6.2"
      sources."nice-try-1.0.5"
      sources."no-case-3.0.4"
      sources."node-abi-3.22.0"
      sources."node-addon-api-3.2.1"
      sources."node-api-version-0.1.4"
      sources."node-fetch-2.6.7"
      sources."node-forge-1.3.0"
      sources."node-gyp-8.4.1"
      sources."node-gyp-build-4.5.0"
      sources."node-int64-0.4.0"
      sources."node-loader-2.0.0"
      sources."node-localstorage-2.2.1"
      sources."node-releases-2.0.5"
      sources."nodejs-file-downloader-4.9.3"
      (sources."nodemon-2.0.18" // {
        dependencies = [
          sources."debug-3.2.7"
          sources."semver-5.7.1"
        ];
      })
      sources."nopt-5.0.0"
      (sources."normalize-package-data-2.5.0" // {
        dependencies = [
          sources."semver-5.7.1"
        ];
      })
      sources."normalize-path-3.0.0"
      sources."normalize-url-4.5.1"
      (sources."npm-conf-1.1.3" // {
        dependencies = [
          sources."pify-3.0.0"
        ];
      })
      (sources."npm-run-path-2.0.2" // {
        dependencies = [
          sources."path-key-2.0.1"
        ];
      })
      sources."npmlog-6.0.2"
      sources."nth-check-2.0.1"
      sources."object-assign-4.1.1"
      sources."object-inspect-1.12.0"
      sources."object-is-1.1.5"
      sources."object-keys-1.1.1"
      sources."object.assign-4.1.2"
      sources."object.entries-1.1.5"
      sources."object.fromentries-2.0.5"
      sources."object.hasown-1.1.1"
      sources."object.values-1.1.5"
      sources."obuf-1.1.2"
      sources."on-finished-2.3.0"
      sources."on-headers-1.0.2"
      sources."once-1.4.0"
      sources."onetime-5.1.2"
      sources."open-8.4.0"
      sources."optionator-0.9.1"
      sources."optipng-bin-7.0.1"
      (sources."ora-5.4.1" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."os-filter-obj-2.0.0"
      sources."os-tmpdir-1.0.2"
      sources."os-utils-0.0.14"
      (sources."ow-0.17.0" // {
        dependencies = [
          sources."type-fest-0.11.0"
        ];
      })
      sources."p-cancelable-1.1.0"
      sources."p-defer-1.0.0"
      sources."p-event-1.3.0"
      sources."p-finally-1.0.0"
      sources."p-is-promise-2.1.0"
      sources."p-limit-3.1.0"
      sources."p-locate-5.0.0"
      sources."p-map-4.0.0"
      sources."p-map-series-1.0.0"
      sources."p-pipe-3.1.0"
      sources."p-reduce-1.0.0"
      (sources."p-retry-4.6.1" // {
        dependencies = [
          sources."retry-0.13.1"
        ];
      })
      sources."p-timeout-1.2.1"
      sources."p-try-2.2.0"
      (sources."package-json-6.5.0" // {
        dependencies = [
          sources."semver-6.3.0"
        ];
      })
      sources."param-case-3.0.4"
      sources."parent-module-1.0.1"
      sources."parse-author-2.0.0"
      (sources."parse-color-1.0.0" // {
        dependencies = [
          sources."color-convert-0.5.3"
        ];
      })
      sources."parse-json-5.2.0"
      sources."parse-ms-2.1.0"
      sources."parse-passwd-1.0.0"
      sources."parseurl-1.3.3"
      sources."pascal-case-3.1.2"
      sources."path-exists-4.0.0"
      sources."path-is-absolute-1.0.1"
      sources."path-key-3.1.1"
      sources."path-parse-1.0.7"
      sources."path-to-regexp-0.1.7"
      sources."path-type-4.0.0"
      sources."pend-1.2.0"
      sources."picocolors-1.0.0"
      sources."picomatch-2.3.1"
      sources."pify-2.3.0"
      sources."pinkie-2.0.4"
      sources."pinkie-promise-2.0.1"
      sources."pirates-4.0.5"
      (sources."pkg-dir-4.2.0" // {
        dependencies = [
          sources."find-up-4.1.0"
          sources."locate-path-5.0.0"
          sources."p-limit-2.3.0"
          sources."p-locate-4.1.0"
        ];
      })
      sources."plist-3.0.6"
      (sources."pngquant-bin-6.0.1" // {
        dependencies = [
          sources."execa-4.1.0"
          sources."get-stream-5.2.0"
          sources."human-signals-1.1.1"
          sources."is-stream-2.0.1"
          sources."npm-run-path-4.0.1"
        ];
      })
      (sources."popmotion-11.0.3" // {
        dependencies = [
          sources."framesync-6.0.1"
        ];
      })
      (sources."portfinder-1.0.32" // {
        dependencies = [
          sources."async-2.6.4"
          sources."debug-3.2.7"
        ];
      })
      sources."postcss-8.4.17"
      sources."postcss-media-query-parser-0.2.3"
      sources."postcss-modules-extract-imports-3.0.0"
      sources."postcss-modules-local-by-default-4.0.0"
      sources."postcss-modules-scope-3.0.0"
      sources."postcss-modules-values-4.0.0"
      sources."postcss-resolve-nested-selector-0.1.1"
      sources."postcss-safe-parser-6.0.0"
      sources."postcss-scss-4.0.5"
      sources."postcss-selector-parser-6.0.10"
      sources."postcss-value-parser-4.2.0"
      sources."prelude-ls-1.2.1"
      sources."prepend-http-2.0.0"
      sources."prettier-2.6.2"
      sources."prettier-linter-helpers-1.0.0"
      sources."pretty-error-4.0.0"
      (sources."pretty-format-27.5.1" // {
        dependencies = [
          sources."ansi-styles-5.2.0"
          sources."react-is-17.0.2"
        ];
      })
      sources."pretty-ms-7.0.1"
      sources."process-0.11.10"
      sources."process-nextick-args-2.0.1"
      sources."progress-2.0.3"
      sources."promise-inflight-1.0.1"
      sources."promise-retry-2.0.1"
      (sources."prompts-2.4.2" // {
        dependencies = [
          sources."kleur-3.0.3"
        ];
      })
      sources."prop-types-15.8.1"
      sources."property-information-6.1.1"
      sources."proto-list-1.2.4"
      sources."proxy-addr-2.0.7"
      sources."pseudomap-1.0.2"
      sources."pstree.remy-1.1.8"
      sources."pump-3.0.0"
      sources."punycode-2.1.1"
      sources."pupa-2.1.1"
      sources."qs-6.9.7"
      sources."query-string-5.1.1"
      sources."queue-microtask-1.2.3"
      sources."quick-lru-5.1.1"
      sources."random-path-0.1.2"
      sources."randombytes-2.1.0"
      sources."range-parser-1.2.1"
      sources."raw-body-2.4.3"
      (sources."rc-1.2.8" // {
        dependencies = [
          sources."strip-json-comments-2.0.1"
        ];
      })
      sources."rcedit-3.0.1"
      sources."re-resizable-6.9.9"
      sources."react-18.1.0"
      sources."react-clientside-effect-1.2.6"
      sources."react-dom-18.1.0"
      sources."react-fast-compare-3.2.0"
      sources."react-focus-lock-2.9.1"
      sources."react-hotkeys-hook-3.4.6"
      sources."react-icons-4.4.0"
      sources."react-is-16.13.1"
      (sources."react-markdown-8.0.3" // {
        dependencies = [
          sources."react-is-18.1.0"
        ];
      })
      sources."react-refresh-0.13.0"
      sources."react-remove-scroll-2.5.3"
      sources."react-remove-scroll-bar-2.3.1"
      sources."react-style-singleton-2.2.0"
      sources."reactflow-11.1.0"
      (sources."read-pkg-2.0.0" // {
        dependencies = [
          sources."path-type-2.0.0"
        ];
      })
      (sources."read-pkg-up-2.0.0" // {
        dependencies = [
          sources."find-up-2.1.0"
          sources."locate-path-2.0.0"
          sources."p-limit-1.3.0"
          sources."p-locate-2.0.0"
          sources."p-try-1.0.0"
          sources."path-exists-3.0.0"
        ];
      })
      sources."readable-stream-2.3.7"
      sources."readdirp-3.6.0"
      sources."redent-3.0.0"
      sources."regenerator-runtime-0.13.9"
      sources."regexp.prototype.flags-1.4.3"
      sources."regexpp-3.2.0"
      sources."registry-auth-token-4.2.1"
      sources."registry-url-5.1.0"
      sources."relateurl-0.2.7"
      sources."remark-parse-10.0.1"
      sources."remark-rehype-10.1.0"
      sources."renderkid-3.0.0"
      sources."repeat-string-1.6.1"
      sources."replace-ext-1.0.1"
      sources."require-directory-2.1.1"
      sources."require-from-string-2.0.2"
      sources."require-main-filename-2.0.0"
      sources."requires-port-1.0.0"
      sources."resolve-1.22.0"
      sources."resolve-alpn-1.2.1"
      (sources."resolve-cwd-3.0.0" // {
        dependencies = [
          sources."resolve-from-5.0.0"
        ];
      })
      sources."resolve-dir-1.0.1"
      sources."resolve-from-4.0.0"
      sources."resolve-package-1.0.1"
      sources."resolve.exports-1.1.0"
      sources."responselike-1.0.2"
      sources."restore-cursor-3.1.0"
      sources."retry-0.12.0"
      sources."reusify-1.0.4"
      sources."rimraf-3.0.2"
      (sources."roarr-2.15.4" // {
        dependencies = [
          sources."sprintf-js-1.1.2"
        ];
      })
      sources."rregex-1.5.1"
      sources."run-async-2.4.1"
      sources."run-parallel-1.2.0"
      (sources."rxjs-6.6.7" // {
        dependencies = [
          sources."tslib-1.14.1"
        ];
      })
      sources."sade-1.8.1"
      sources."safe-buffer-5.1.2"
      sources."safer-buffer-2.1.2"
      sources."sanitize-filename-1.6.3"
      sources."sass-1.54.4"
      sources."sass-loader-13.0.2"
      sources."scheduler-0.22.0"
      sources."schema-utils-2.7.1"
      (sources."seek-bzip-1.0.6" // {
        dependencies = [
          sources."commander-2.20.3"
        ];
      })
      sources."select-hose-2.0.0"
      sources."selfsigned-2.0.0"
      sources."semver-7.3.7"
      sources."semver-compare-1.0.0"
      (sources."semver-diff-3.1.1" // {
        dependencies = [
          sources."semver-6.3.0"
        ];
      })
      sources."semver-regex-4.0.3"
      (sources."semver-truncate-1.1.2" // {
        dependencies = [
          sources."semver-5.7.1"
        ];
      })
      (sources."send-0.17.2" // {
        dependencies = [
          (sources."debug-2.6.9" // {
            dependencies = [
              sources."ms-2.0.0"
            ];
          })
          sources."ms-2.1.3"
        ];
      })
      (sources."serialize-error-7.0.1" // {
        dependencies = [
          sources."type-fest-0.13.1"
        ];
      })
      sources."serialize-javascript-6.0.0"
      (sources."serve-index-1.9.1" // {
        dependencies = [
          sources."debug-2.6.9"
          sources."http-errors-1.6.3"
          sources."inherits-2.0.3"
          sources."ms-2.0.0"
          sources."setprototypeof-1.1.0"
        ];
      })
      sources."serve-static-1.14.2"
      sources."set-blocking-2.0.0"
      sources."setprototypeof-1.2.0"
      sources."shallow-clone-3.0.1"
      sources."shebang-command-2.0.0"
      sources."shebang-regex-3.0.0"
      sources."shell-quote-1.7.3"
      sources."side-channel-1.0.4"
      sources."signal-exit-3.0.7"
      sources."sisteransi-1.0.5"
      sources."slash-3.0.0"
      (sources."slice-ansi-4.0.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
        ];
      })
      sources."slide-1.1.6"
      sources."smart-buffer-4.2.0"
      sources."sockjs-0.3.24"
      sources."socks-2.6.2"
      sources."socks-proxy-agent-6.2.1"
      sources."sort-keys-1.1.2"
      sources."sort-keys-length-1.0.1"
      sources."source-map-0.5.7"
      sources."source-map-js-1.0.2"
      (sources."source-map-support-0.5.21" // {
        dependencies = [
          sources."source-map-0.6.1"
        ];
      })
      sources."space-separated-tokens-2.0.1"
      sources."spawn-command-0.0.2-1"
      sources."spdx-correct-3.1.1"
      sources."spdx-exceptions-2.3.0"
      sources."spdx-expression-parse-3.0.1"
      sources."spdx-license-ids-3.0.11"
      sources."spdy-4.0.2"
      (sources."spdy-transport-3.0.0" // {
        dependencies = [
          sources."readable-stream-3.6.0"
        ];
      })
      sources."sprintf-js-1.0.3"
      sources."ssri-8.0.1"
      sources."stable-0.1.8"
      (sources."stack-utils-2.0.5" // {
        dependencies = [
          sources."escape-string-regexp-2.0.0"
        ];
      })
      sources."stackframe-1.2.1"
      sources."statuses-1.5.0"
      sources."stream-buffers-2.2.0"
      sources."strict-uri-encode-1.1.0"
      sources."string-length-4.0.2"
      (sources."string-width-4.2.3" // {
        dependencies = [
          sources."emoji-regex-8.0.0"
        ];
      })
      sources."string.prototype.matchall-4.0.7"
      sources."string.prototype.trimend-1.0.5"
      sources."string.prototype.trimstart-1.0.5"
      sources."string_decoder-1.1.1"
      sources."strip-ansi-6.0.1"
      sources."strip-bom-3.0.0"
      sources."strip-dirs-2.1.0"
      sources."strip-eof-1.0.0"
      sources."strip-final-newline-2.0.0"
      sources."strip-indent-3.0.0"
      sources."strip-json-comments-3.1.1"
      (sources."strip-outer-1.0.1" // {
        dependencies = [
          sources."escape-string-regexp-1.0.5"
        ];
      })
      sources."strnum-1.0.5"
      sources."style-loader-3.3.1"
      sources."style-search-0.1.0"
      sources."style-to-object-0.3.0"
      sources."style-value-types-5.0.0"
      (sources."stylelint-14.13.0" // {
        dependencies = [
          sources."balanced-match-2.0.0"
          sources."cosmiconfig-7.0.1"
          sources."global-modules-2.0.0"
          sources."global-prefix-3.0.0"
          sources."globby-11.1.0"
          sources."import-lazy-4.0.0"
          sources."resolve-from-5.0.0"
          sources."which-1.3.1"
          sources."write-file-atomic-4.0.2"
        ];
      })
      sources."stylelint-config-prettier-9.0.3"
      sources."stylelint-config-prettier-scss-0.0.1"
      sources."stylelint-config-recommended-8.0.0"
      sources."stylelint-config-recommended-scss-7.0.0"
      sources."stylelint-config-standard-26.0.0"
      sources."stylelint-config-standard-scss-5.0.0"
      sources."stylelint-prettier-2.0.0"
      sources."stylelint-scss-4.3.0"
      sources."stylis-4.0.13"
      sources."sudo-prompt-9.2.1"
      sources."sumchecker-3.0.1"
      sources."supports-color-5.5.0"
      (sources."supports-hyperlinks-2.3.0" // {
        dependencies = [
          sources."has-flag-4.0.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."supports-preserve-symlinks-flag-1.0.0"
      sources."svg-tags-1.0.0"
      (sources."svgo-2.8.0" // {
        dependencies = [
          sources."commander-7.2.0"
        ];
      })
      sources."systeminformation-5.11.16"
      (sources."table-6.8.0" // {
        dependencies = [
          sources."ajv-8.11.0"
          sources."json-schema-traverse-1.0.0"
        ];
      })
      sources."tapable-2.2.1"
      (sources."tar-6.1.11" // {
        dependencies = [
          sources."mkdirp-1.0.4"
        ];
      })
      (sources."tar-stream-1.6.2" // {
        dependencies = [
          sources."bl-1.2.3"
        ];
      })
      (sources."temp-0.9.4" // {
        dependencies = [
          sources."rimraf-2.6.3"
        ];
      })
      sources."temp-dir-1.0.0"
      (sources."tempfile-2.0.0" // {
        dependencies = [
          sources."uuid-3.4.0"
        ];
      })
      sources."terminal-link-2.1.1"
      (sources."terser-5.14.2" // {
        dependencies = [
          sources."commander-2.20.3"
        ];
      })
      (sources."terser-webpack-plugin-5.3.1" // {
        dependencies = [
          sources."schema-utils-3.1.1"
          sources."source-map-0.6.1"
        ];
      })
      sources."test-exclude-6.0.0"
      sources."text-table-0.2.0"
      sources."throat-6.0.1"
      sources."through-2.3.8"
      sources."thunky-1.1.0"
      sources."timed-out-4.0.1"
      sources."tiny-each-async-2.0.3"
      sources."tiny-invariant-1.2.0"
      sources."tmp-0.0.33"
      (sources."tmp-promise-3.0.3" // {
        dependencies = [
          sources."tmp-0.2.1"
        ];
      })
      sources."tmpl-1.0.5"
      sources."tn1150-0.1.0"
      sources."to-buffer-1.1.1"
      sources."to-data-view-1.1.0"
      sources."to-fast-properties-2.0.0"
      sources."to-readable-stream-1.0.0"
      sources."to-regex-range-5.0.1"
      sources."toggle-selection-1.0.6"
      sources."toidentifier-1.0.1"
      (sources."touch-3.1.0" // {
        dependencies = [
          sources."nopt-1.0.10"
        ];
      })
      sources."tr46-0.0.3"
      sources."tree-kill-1.2.2"
      sources."trim-newlines-3.0.1"
      (sources."trim-repeated-1.0.0" // {
        dependencies = [
          sources."escape-string-regexp-1.0.5"
        ];
      })
      sources."trough-2.1.0"
      sources."truncate-utf8-bytes-1.0.2"
      sources."ts-jest-28.0.3"
      (sources."ts-node-10.8.0" // {
        dependencies = [
          sources."diff-4.0.2"
        ];
      })
      (sources."tsconfig-paths-3.14.1" // {
        dependencies = [
          sources."json5-1.0.1"
        ];
      })
      sources."tslib-2.3.1"
      (sources."tsutils-3.21.0" // {
        dependencies = [
          sources."tslib-1.14.1"
        ];
      })
      sources."tunnel-0.0.6"
      sources."tunnel-agent-0.6.0"
      sources."type-check-0.4.0"
      sources."type-detect-4.0.8"
      sources."type-fest-0.21.3"
      sources."type-is-1.6.18"
      sources."typedarray-to-buffer-3.1.5"
      sources."typescript-4.7.2"
      sources."unbox-primitive-1.0.2"
      sources."unbzip2-stream-1.4.3"
      sources."undefsafe-2.0.5"
      (sources."unified-10.1.2" // {
        dependencies = [
          sources."is-plain-obj-4.0.0"
        ];
      })
      sources."unique-filename-1.1.1"
      sources."unique-slug-2.0.2"
      sources."unique-string-2.0.0"
      sources."unist-builder-3.0.0"
      sources."unist-util-generated-2.0.0"
      sources."unist-util-is-5.1.1"
      sources."unist-util-position-4.0.3"
      sources."unist-util-stringify-position-3.0.2"
      sources."unist-util-visit-4.1.0"
      sources."unist-util-visit-parents-5.1.0"
      sources."universal-user-agent-6.0.0"
      sources."universalify-2.0.0"
      sources."unorm-1.6.0"
      sources."unpipe-1.0.0"
      (sources."update-notifier-5.1.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."chalk-4.1.2"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
          sources."has-flag-4.0.0"
          sources."import-lazy-2.1.0"
          sources."supports-color-7.2.0"
        ];
      })
      sources."uri-js-4.4.1"
      sources."url-parse-lax-3.0.0"
      sources."url-to-options-1.0.1"
      sources."use-callback-ref-1.3.0"
      sources."use-context-selector-1.4.0"
      sources."use-debounce-8.0.1"
      (sources."use-http-1.0.26" // {
        dependencies = [
          sources."urs-0.0.8"
          sources."use-ssr-1.0.24"
        ];
      })
      sources."use-sidecar-1.1.2"
      sources."use-sync-external-store-1.2.0"
      sources."username-5.1.0"
      sources."utf8-byte-length-1.0.4"
      sources."util-deprecate-1.0.2"
      sources."utila-0.4.0"
      sources."utility-types-3.10.0"
      sources."utils-merge-1.0.1"
      sources."uuid-8.3.2"
      sources."uvu-0.5.3"
      sources."v8-compile-cache-2.3.0"
      sources."v8-compile-cache-lib-3.0.1"
      sources."v8-to-istanbul-9.0.0"
      sources."validate-npm-package-license-3.0.4"
      sources."vary-1.1.2"
      sources."vfile-5.3.2"
      sources."vfile-message-3.1.2"
      sources."walker-1.0.8"
      sources."watchpack-2.3.1"
      sources."wbuf-1.7.3"
      sources."wcwidth-1.0.1"
      sources."webidl-conversions-3.0.1"
      (sources."webpack-5.70.0" // {
        dependencies = [
          sources."acorn-import-assertions-1.8.0"
          sources."schema-utils-3.1.1"
        ];
      })
      (sources."webpack-dev-middleware-5.3.1" // {
        dependencies = [
          sources."ajv-8.10.0"
          sources."ajv-keywords-5.1.0"
          sources."json-schema-traverse-1.0.0"
          sources."schema-utils-4.0.0"
        ];
      })
      (sources."webpack-dev-server-4.7.4" // {
        dependencies = [
          sources."ajv-8.10.0"
          sources."ajv-keywords-5.1.0"
          sources."ansi-regex-6.0.1"
          sources."ipaddr.js-2.0.1"
          sources."json-schema-traverse-1.0.0"
          sources."schema-utils-4.0.0"
          sources."strip-ansi-7.0.1"
          sources."ws-8.5.0"
        ];
      })
      sources."webpack-merge-5.8.0"
      sources."webpack-sources-3.2.3"
      sources."websocket-driver-0.7.4"
      sources."websocket-extensions-0.1.4"
      sources."whatwg-url-5.0.0"
      sources."which-2.0.2"
      sources."which-boxed-primitive-1.0.2"
      sources."which-module-2.0.0"
      sources."wide-align-1.1.5"
      sources."widest-line-3.1.0"
      sources."wildcard-2.0.0"
      sources."word-wrap-1.2.3"
      (sources."wrap-ansi-7.0.0" // {
        dependencies = [
          sources."ansi-styles-4.3.0"
          sources."color-convert-2.0.1"
          sources."color-name-1.1.4"
        ];
      })
      sources."wrappy-1.0.2"
      sources."write-file-atomic-1.3.4"
      sources."ws-7.5.9"
      sources."xdg-basedir-4.0.0"
      sources."xmlbuilder-15.1.1"
      sources."xtend-4.0.2"
      sources."xterm-4.19.0"
      sources."xterm-addon-fit-0.5.0"
      sources."xterm-addon-search-0.8.2"
      sources."y18n-5.0.8"
      sources."yallist-4.0.0"
      sources."yaml-1.10.2"
      (sources."yargs-17.5.1" // {
        dependencies = [
          sources."yargs-parser-21.0.1"
        ];
      })
      sources."yargs-parser-20.2.9"
      (sources."yarn-or-npm-3.0.1" // {
        dependencies = [
          sources."cross-spawn-6.0.5"
          sources."path-key-2.0.1"
          sources."semver-5.7.1"
          sources."shebang-command-1.2.0"
          sources."shebang-regex-1.0.0"
          sources."which-1.3.1"
        ];
      })
      sources."yauzl-2.10.0"
      sources."yn-3.1.1"
      sources."yocto-queue-0.1.0"
      sources."zustand-4.1.1"
    ];
    buildInputs = globalBuildInputs;
    meta = {
      description = "A flowchart based image processing GUI";
      license = "GPLv3";
    };
    production = false;
    bypassCache = true;
    reconstructLock = false;
  }
