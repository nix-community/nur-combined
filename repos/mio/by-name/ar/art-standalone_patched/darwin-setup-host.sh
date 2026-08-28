#!/usr/bin/env bash
# Darwin-only host setup that cannot be expressed as source patches (symlinks, pruning).
set -euo pipefail

prebuilt_bin=prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin
mkdir -p "$prebuilt_bin"
ln -sf "$(command -v c++)" "$prebuilt_bin/i686-apple-darwin10-g++"
ln -sf "$(command -v cc)" "$prebuilt_bin/i686-apple-darwin10-gcc"
ln -sf "$(command -v ar)" "$prebuilt_bin/i686-apple-darwin10-ar"
ln -sf "$(command -v nm)" "$prebuilt_bin/i686-apple-darwin10-nm"
ln -sf "$(command -v ld)" "$prebuilt_bin/i686-apple-darwin10-ld"

rm -rf adb dalvik/dexdump dalvik/libdex build/tools/check_prereq
rm -f \
  build/core/tasks/cts.mk \
  build/core/tasks/boot_jars_package_check.mk \
  external/icu/android_icu4j/Android.mk
