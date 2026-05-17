{ lib, callPackage }:

# Deprecated alias: opencode-sst was renamed to opencode after upstream
# repository moved from sst/opencode to anomalyco/opencode.
lib.warn ''
  opencode-sst has been renamed to opencode
  (upstream repository moved from sst/opencode to anomalyco/opencode).
  Please update your configuration to use `opencode` instead.
'' (callPackage ../opencode { })
