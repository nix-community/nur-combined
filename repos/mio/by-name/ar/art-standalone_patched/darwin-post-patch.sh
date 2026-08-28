#!/usr/bin/env bash
# Darwin host build fixes for art-standalone (invoked from package.nix postPatch).
set -euo pipefail

: "${PYTHON:?}"
: "${VIXL_INCLUDE:?}"
: "${ASM_UNDERSCORE_SCRIPT:?}"
: "${ELF_HEADER:?}"
: "${EPOLL_HEADER:?}"
: "${LINK_HEADER:?}"

cp build/core/combo/HOST_darwin-x86.mk build/core/combo/HOST_darwin-arm.mk
cp build/core/combo/HOST_darwin-x86.mk build/core/combo/HOST_darwin-arm64.mk
find . -type f \( -name "*.mk" -o -name "Makefile" \) -exec sed -i -E \
  -e 's/-arch [a-zA-Z0-9_]+//g' -e 's/-m32\b//g' -e 's/-m64\b//g' {} +
sed -i 's/dladdr(art_sigsegv_fault/dladdr(reinterpret_cast<const void*>(art_sigsegv_fault)/g' \
  art/dex2oat/dex2oat.cc art/runtime/parsed_options.cc art/runtime/runtime.cc
sed -i -E 's/char \*libart_so_full_path = malloc\((.*)\);/char *libart_so_full_path = static_cast<char*>(malloc(\1));/' \
  art/runtime/parsed_options.cc
mkdir -p prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin
ln -sf "$(command -v c++)" prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-g++
ln -sf "$(command -v cc)" prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-gcc
ln -sf "$(command -v ar)" prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-ar
ln -sf "$(command -v nm)" prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-nm
ln -sf "$(command -v ld)" prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-ld
sed -i 's/\$(error/\$(info/g' build/core/main.mk
sed -i 's/\$(error/\$(info/g' build/core/combo/mac_version.mk
sed -i 's/\$(error HOST_OS must define.*/\$(info Ignore)/g' build/core/definitions.mk
sed -i 's/\$(error.*already defined by.*)/\$(info Ignore redefined module)/g' build/core/base_rules.mk
sed -i \
  -e 's/-isysroot $(mac_sdk_root)//g' \
  -e 's/-isysroot \/Developer\/SDKs\/MacOSX10.6.sdk//g' \
  -e 's/-mmacosx-version-min=$(mac_sdk_version)//g' \
  -e 's/-mmacosx-version-min=10.6//g' \
  -e 's/-DMACOSX_DEPLOYMENT_TARGET=$(mac_sdk_version)//g' \
  build/core/combo/HOST_darwin-*.mk
echo -e "define get-file-size\nstat -f \"%z\" \$\$1\nendef" >> build/core/config.mk
sed -i 's/art::Runtime::callee_save_methods_/callee_save_methods_/g' art/runtime/runtime.h
find . -type f \( -name "*.mk" -o -name "Makefile" \) -exec sed -i -E -e 's/libunwind//g' {} +
sed -i '1i #include <stdbool.h>' system/core/liblog/fake_log_device.c
sed -i 's/if (char \*liblog_color = getenv("LIBLOG_COLOR"))/char \*liblog_color = getenv("LIBLOG_COLOR");\n    if (liblog_color)/g' \
  system/core/liblog/fake_log_device.c
sed -i '1i typedef void (*sighandler_t)(int);' art/sigchainlib/sigchain.h
echo "#include <sys/uio.h>" > system/core/include/log/uio.h
mkdir -p system/core/include/sys
cp "$ELF_HEADER" system/core/include/elf.h
cp "$EPOLL_HEADER" system/core/include/sys/epoll.h
sed -i '/static_assert/d' system/core/libutils/include/utils/Compat.h
sed -i '/Looper/d' system/core/libutils/Android.mk
sed -i '/Looper/d' system/core/libutils/Android.bp
find . -type f \( -name "*.mk" -o -name "Makefile" -o -name "*.bp" \) -exec sed -i 's/-Werror//g' {} +
sed -i -e '/libdex/d' -e '/dexdump/d' dalvik/Android.mk
find external libcore -name Android.mk -exec sed -i \
  's/ifeq ($(WITH_HOST_DALVIK),true)/ifneq ($(HOST_OS),windows)/g' {} +
rm -f build/core/tasks/cts.mk build/core/tasks/boot_jars_package_check.mk
rm -rf adb dalvik/dexdump dalvik/libdex build/tools/check_prereq
sed -i '/libgtest/d' build/core/host_test_internal.mk build/core/target_test_internal.mk
sed -i '71,73d' system/core/libbacktrace/Android.mk
sed -i '78,136d' system/core/libbacktrace/Android.mk
sed -i 's/boot-jars-package-check//g' build/core/main.mk
sed -i '/include $(BUILD_SYSTEM)\/Makefile/d' build/core/main.mk
find external -name Android.mk -exec sed -i \
  -e '/include $(BUILD_JAVA_LIBRARY)/d' \
  -e '/include $(BUILD_STATIC_JAVA_LIBRARY)/d' {} +
rm -f external/icu/android_icu4j/Android.mk

sed -i "s|-I/usr/local/include/vixl|-I${VIXL_INCLUDE}|g" art/build/Android.common_build.mk
sed -i 's/libvixld//g' art/disassembler/Android.mk

sed -i 's/#include <byteswap.h>/#ifndef __APPLE__\n#include <byteswap.h>\n#else\n#include <libkern\/OSByteOrder.h>\n#define bswap_16 OSSwapInt16\n#define bswap_32 OSSwapInt32\n#define bswap_64 OSSwapInt64\n#endif/' \
  libcore/luni/src/main/native/Portability.h
sed -i 's/#include <sys\/sendfile.h>/#ifndef __APPLE__\n#include <sys\/sendfile.h>\n#endif/' \
  libcore/luni/src/main/native/Portability.h libcore/luni/src/main/native/libcore_io_Linux.cpp
sed -i 's/#include <sys\/prctl.h>/#ifndef __APPLE__\n#include <sys\/prctl.h>\n#endif/' \
  libcore/luni/src/main/native/android_system_OsConstants.cpp libcore/luni/src/main/native/libcore_io_Linux.cpp
sed -i '/netpacket\/packet\.h/d; /sys\/capability\.h/d; /linux\/if_ether\.h/d; /linux\/if_addr\.h/d; /linux\/rtnetlink\.h/d; /linux\/udp\.h/d; /linux\/capability\.h/d' \
  libcore/luni/src/main/native/android_system_OsConstants.cpp libcore/luni/src/main/native/libcore_io_Linux.cpp
sed -i '/ETH_P_/d; /RTMGRP_/d; /UDP_ENCAP/d; /AF_PACKET/d; /AF_NETLINK/d' \
  libcore/luni/src/main/native/android_system_OsConstants.cpp
sed -i '/RT_SCOPE_/d; /ST_MANDLOCK/d; /ST_NOATIME/d; /ST_NODEV/d; /ST_NODIRATIME/d; /ST_NOEXEC/d; /ST_RELATIME/d; /ST_SYNCHRONOUS/d' \
  libcore/luni/src/main/native/android_system_OsConstants.cpp
sed -i '/ARPHRD_LOOPBACK/d; /ENONET/d; /IP_MULTICAST_ALL/d; /MAP_POPULATE/d; /NETLINK_NETFILTER/d; /NETLINK_ROUTE/d' \
  libcore/luni/src/main/native/android_system_OsConstants.cpp
find libandroidfw libziparchive libcore/ojluni/src/main/native -type f -exec sed -i -E \
  -e '/^#define F_SETLK/d' \
  -e 's/off64_t/off_t/g' \
  -e 's/flock64/flock/g' \
  -e 's/dirent64/dirent/g' \
  -e 's/F_SETLKW64/F_SETLKW/g' \
  -e 's/F_SETLK64/F_SETLK/g' \
  -e 's/android-base\/off_t\.h/android-base\/off64_t.h/g' \
  -e 's/open64/open/g' \
  -e 's/lseek64/lseek/g' \
  -e 's/pread64/pread/g' \
  -e 's/pwrite64/pwrite/g' \
  -e 's/ftruncate64/ftruncate/g' \
  -e 's/mmap64/mmap/g' \
  -e 's/readdir64/readdir/g' \
  -e 's/statvfs64/statvfs/g' \
  -e 's/stat64/stat/g' \
  -e 's/fstat64/fstat/g' \
  -e 's/lstat64/lstat/g' {} +
sed -i -e '/LinuxNativeDispatcher\.c/d' -e '/LinuxWatchService\.c/d' \
  libcore/ojluni/src/main/native/openjdksub.mk
sed -i 's|#include <wait.h>|#include <sys/wait.h>|' libcore/ojluni/src/main/native/UNIXProcess_md.c

find build/core/combo -name "HOST_darwin-*.mk" -exec bash -c \
  'echo "HOST_GLOBAL_LDFLAGS += -Wl,-undefined,dynamic_lookup" >> "$1"' _ {} \;
find . -type f \( -name "Android.mk" -o -name "Android.*.mk" \) -exec sed -i -e 's/-Wl,--export-dynamic//g' {} +
find art/runtime/arch art/runtime/interpreter/mterp -type f -name "*.S" -exec sed -i -E \
  -e 's/\.fnstart//g' -e 's/\.fnend//g' \
  -e '/\.size/d' -e '/\.type/d' -e '/\.hidden/d' -e '/\.cfi_/d' {} +

# Mach-O symbol naming for arm64 asm (ENTRY aliases, bl/b targets).
"$PYTHON" "$ASM_UNDERSCORE_SCRIPT"

find art -type f \( -name "*.mk" -o -name "*.bp" \) -exec sed -i -E -e 's/-latomic//g' {} +
sed -i -E \
  -e 's/\.macro LOADREG counter size register return/.macro LOADREG counter, size, register, return/' \
  -e 's/\.macro ALLOC_OBJECT_TLAB_FAST_PATH_RESOLVED slowPathLabel isInitialized/.macro ALLOC_OBJECT_TLAB_FAST_PATH_RESOLVED slowPathLabel, isInitialized/' \
  -e 's/LOADREG ([^ ,]+) ([^ ,]+) ([^ ,]+) ([^ ,]+)/LOADREG \1, \2, \3, \4/g' \
  -e 's/:got:_ZN3art7Runtime9instance_E/__ZN3art7Runtime9instance_E@GOTPAGE/g' \
  -e 's/#:got_lo12:_ZN3art7Runtime9instance_E/__ZN3art7Runtime9instance_E@GOTPAGEOFF/g' \
  art/runtime/arch/arm64/quick_entrypoints_arm64.S
sed -i \
  -e 's/static constexpr uint64_t gZero/static constexpr uintptr_t gZero/' \
  -e 's/const_cast<uint64_t\*>(&gZero)/const_cast<uintptr_t*>(\&gZero)/' \
  -e 's/fprs_\[fp_reg\] = CalleeSaveAddress(frame, spill_pos, frame_info.FrameSizeInBytes());/fprs_[fp_reg] = reinterpret_cast<uint64_t*>(CalleeSaveAddress(frame, spill_pos, frame_info.FrameSizeInBytes()));/' \
  -e 's/DCHECK_NE(fprs_\[reg\], \&gZero)/DCHECK_NE(fprs_[reg], reinterpret_cast<const uint64_t*>(\&gZero))/' \
  art/runtime/arch/arm64/context_arm64.cc
sed -i 's|#include "runtime.h"|#include "runtime.h"\n#include <crt_externs.h>|' \
  art/runtime/exec_utils.cc
sed -i 's/execvpe(program, \&args\[0\], envp);/{ *_NSGetEnviron() = envp; execvp(program, \&args[0]); }/' \
  art/runtime/exec_utils.cc
sed -i 's/char\* bionic_dlerror_msg = bionic_dlerror();/const char* bionic_dlerror_msg = bionic_dlerror();/' \
  art/runtime/ti/agent.cc
cp "$LINK_HEADER" system/core/include/link.h
sed -i \
  -e '/CHECK(libjavacore_loaded_);/d' \
  -e '/CHECK(libnativehelper_loaded_);/d' \
  -e '/CHECK(libopenjdk_loaded_);/d' \
  art/runtime/jni/jni_internal.cc
sed -i -E \
  -e 's/const jvalue\* vargs/jvalue* vargs/g' \
  -e 's/const jvalue\* args/jvalue* args/g' \
  art/runtime/jni/check_jni.cc art/runtime/jni/jni_internal.cc
sed -i 's/findstring aarch64,$(ARCH)/findstring aarch64,$(ARCH))$(findstring arm64,$(ARCH)/' \
  build/core/envsetup.mk
sed -i 's/ifeq ($(HOST_OS),linux)/ifneq ($(HOST_OS),windows)/' \
  libcore/NativeCode.mk libcore/JavaLibrary.mk build/core/host_dalvik_java_library.mk
sed -i 's/ -lrt//g' libcore/NativeCode.mk
sed -i 's/ifeq ($(HOST_OS),linux)/ifneq ($(HOST_OS),windows)/' external/okhttp/Android.mk
sed -i 's/"libart\.so"/"libart.dylib"/' libnativehelper/JniInvocation.cpp
printf '%s\n' '#!/bin/sh' 'exit 0' > build/tools/check_radio_versions.py
chmod +x build/tools/check_radio_versions.py
echo -e "\nsystemimage:\n\t@echo Dummy systemimage\n" >> build/core/main.mk
sed -i \
  -e 's|out/host/linux-x86|out/host/darwin-x86|g' \
  -e 's|lib64/lib\([A-Za-z0-9_-]*\)\.so|lib64/lib\1.dylib|g' \
  -e '/lib64\/\.so/d' \
  -e '/lib64\/\.dylib/d' \
  Makefile
