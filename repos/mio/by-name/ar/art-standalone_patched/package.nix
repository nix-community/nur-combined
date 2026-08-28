{
  art-standalone,
  lib,
  stdenv,
  bionic-translation_patched,
  vixl,
  wolfssl,
  libcap,
  ...
}:

let
  vixl_patched = vixl.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      find . -type f -exec sed -i -E -e 's/-Werror//g' -e 's/werror=true/werror=false/g' -e 's/operator"" _h/operator""_h/g' {} + || true
    '';
  });
in
art-standalone.overrideAttrs (old: {
  pname = "art-standalone-patched";

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.hostPlatform.isDarwin "-D_ALLBSD_SOURCE -DSIGRTMIN=32 -DSIGRTMAX=64";

  patches =
    builtins.filter (p: baseNameOf (toString p) != "remove-wolfssljni.patch") (old.patches or [ ])
    ++ [
      ./dx-workaround.patch
      ./art-datetime-formatter-lambda-crash.patch
      ./dex2oat-path.patch
      ./wolfssljni-freed-session-timeout.patch
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      ./darwin-libcore.patch
      ./darwin-fault-handler-arm64.patch
    ];

  buildInputs =
    builtins.filter (
      drv:
      let
        name = lib.getName drv;
      in
      name != "libcap" && name != "bionic-translation"
    ) (old.buildInputs or [ ])
    ++ lib.optionals stdenv.hostPlatform.isLinux [ libcap ]
    ++ [
      bionic-translation_patched
      ((wolfssl.override { enableJni = true; }).overrideAttrs (_: {
        doCheck = false;
      }))
      vixl_patched
    ];

  postPatch =
    (old.postPatch or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
          cp build/core/combo/HOST_darwin-x86.mk build/core/combo/HOST_darwin-arm.mk
          cp build/core/combo/HOST_darwin-x86.mk build/core/combo/HOST_darwin-arm64.mk
          find . -type f \( -name "*.mk" -o -name "Makefile" \) -exec sed -i -E -e 's/-arch [a-zA-Z0-9_]+//g' -e 's/-m32\b//g' -e 's/-m64\b//g' {} +
          sed -i 's/dladdr(art_sigsegv_fault/dladdr(reinterpret_cast<const void*>(art_sigsegv_fault)/g' \
            art/dex2oat/dex2oat.cc art/runtime/parsed_options.cc art/runtime/runtime.cc
          sed -i -E 's/char \*libart_so_full_path = malloc\((.*)\);/char *libart_so_full_path = static_cast<char*>(malloc(\1));/' \
            art/runtime/parsed_options.cc
          mkdir -p prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin
          ln -s $(which c++) prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-g++
          ln -s $(which cc) prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-gcc
          ln -s $(which ar) prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-ar
          ln -s $(which nm) prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-nm
          ln -s $(which ld) prebuilts/gcc/darwin-x86/host/i686-apple-darwin-4.2.1/bin/i686-apple-darwin10-ld
          sed -i 's/\$(error/\$(info/g' build/core/main.mk
          sed -i 's/\$(error/\$(info/g' build/core/combo/mac_version.mk
          # darwin-libcore.patch handles libcore_io_Linux.cpp compatibility
          sed -i 's/\$(error HOST_OS must define.*/\$(info Ignore)/g' build/core/definitions.mk
          sed -i 's/\$(error.*already defined by.*)/\$(info Ignore redefined module)/g' build/core/base_rules.mk
          sed -i -e 's/-isysroot \$(mac_sdk_root)//g' -e 's/-isysroot \/Developer\/SDKs\/MacOSX10.6.sdk//g' -e 's/-mmacosx-version-min=\$(mac_sdk_version)//g' -e 's/-mmacosx-version-min=10.6//g' -e 's/-DMACOSX_DEPLOYMENT_TARGET=\$(mac_sdk_version)//g' build/core/combo/HOST_darwin-*.mk
          echo -e "define get-file-size\nstat -f \"%z\" \$\$1\nendef" >> build/core/config.mk
          sed -i 's/art::Runtime::callee_save_methods_/callee_save_methods_/g' art/runtime/runtime.h
          find . -type f \( -name "*.mk" -o -name "Makefile" \) -exec sed -i -E -e 's/libunwind//g' {} +
          sed -i '1i #include <stdbool.h>' system/core/liblog/fake_log_device.c
          sed -i 's/if (char \*liblog_color = getenv("LIBLOG_COLOR"))/char \*liblog_color = getenv("LIBLOG_COLOR");\n    if (liblog_color)/g' system/core/liblog/fake_log_device.c
          sed -i '1i typedef void (*sighandler_t)(int);' art/sigchainlib/sigchain.h
          echo "#include <sys/uio.h>" > system/core/include/log/uio.h
          mkdir -p system/core/include/sys
          cat <<'EOF_EPOLL' > system/core/include/sys/epoll.h
      #ifndef _SYS_EPOLL_H
      #define _SYS_EPOLL_H
      #include <stdint.h>
      #ifdef __cplusplus
      extern "C" {
      #endif
      typedef union epoll_data { void *ptr; int fd; uint32_t u32; uint64_t u64; } epoll_data_t;
      struct epoll_event { uint32_t events; epoll_data_t data; };
      #define EPOLLIN 1
      #define EPOLLWAKEUP 2
      #define EPOLLOUT 4
      #define EPOLLERR 8
      #define EPOLLHUP 16
      #define EPOLL_CTL_ADD 1
      #define EPOLL_CTL_DEL 2
      #define EPOLL_CTL_MOD 3
      #define EPOLL_CLOEXEC 0
      static inline int epoll_create(int size) { return -1; }
      static inline int epoll_create1(int flags) { return -1; }
      static inline int epoll_ctl(int epfd, int op, int fd, struct epoll_event *event) { return -1; }
      static inline int epoll_wait(int epfd, struct epoll_event *events, int maxevents, int timeout) { return -1; }
      #ifdef __cplusplus
      }
      #endif
      #endif
      EOF_EPOLL
          sed -i '/static_assert/d' system/core/libutils/include/utils/Compat.h
          sed -i '/Looper/d' system/core/libutils/Android.mk
          sed -i '/Looper/d' system/core/libutils/Android.bp
          cp ${./elf.h} system/core/include/elf.h
          find . -type f \( -name "*.mk" -o -name "Makefile" -o -name "*.bp" \) -exec sed -i 's/-Werror//g' {} +
          sed -i -e '/libdex/d' -e '/dexdump/d' dalvik/Android.mk
          find external libcore -name Android.mk -exec sed -i 's/ifeq ($(WITH_HOST_DALVIK),true)/ifneq ($(HOST_OS),windows)/g' {} +
          rm -f build/core/tasks/cts.mk build/core/tasks/boot_jars_package_check.mk
          rm -rf adb dalvik/dexdump dalvik/libdex build/tools/check_prereq
          sed -i '/libgtest/d' build/core/host_test_internal.mk build/core/target_test_internal.mk
          sed -i '71,73d' system/core/libbacktrace/Android.mk
          sed -i '78,136d' system/core/libbacktrace/Android.mk
          sed -i 's/boot-jars-package-check//g' build/core/main.mk
          sed -i '/include $(BUILD_SYSTEM)\/Makefile/d' build/core/main.mk
          find external -name Android.mk -exec sed -i -e '/include \$(BUILD_JAVA_LIBRARY)/d' -e '/include \$(BUILD_STATIC_JAVA_LIBRARY)/d' {} +
          rm -f external/icu/android_icu4j/Android.mk

          sed -i "s|-I/usr/local/include/vixl|-I${vixl_patched}/include/vixl|g" art/build/Android.common_build.mk
          sed -i 's/libvixld//g' art/disassembler/Android.mk

          sed -i 's/#include <byteswap.h>/#ifndef __APPLE__\n#include <byteswap.h>\n#else\n#include <libkern\/OSByteOrder.h>\n#define bswap_16 OSSwapInt16\n#define bswap_32 OSSwapInt32\n#define bswap_64 OSSwapInt64\n#endif/' libcore/luni/src/main/native/Portability.h
          sed -i 's/#include <sys\/sendfile.h>/#ifndef __APPLE__\n#include <sys\/sendfile.h>\n#endif/' libcore/luni/src/main/native/Portability.h libcore/luni/src/main/native/libcore_io_Linux.cpp
          sed -i 's/#include <sys\/prctl.h>/#ifndef __APPLE__\n#include <sys\/prctl.h>\n#endif/' libcore/luni/src/main/native/android_system_OsConstants.cpp libcore/luni/src/main/native/libcore_io_Linux.cpp
          if [ "$(uname)" = "Darwin" ]; then
              sed -i '/netpacket\/packet\.h/d; /sys\/capability\.h/d; /linux\/if_ether\.h/d; /linux\/if_addr\.h/d; /linux\/rtnetlink\.h/d; /linux\/udp\.h/d; /linux\/capability\.h/d' libcore/luni/src/main/native/android_system_OsConstants.cpp libcore/luni/src/main/native/libcore_io_Linux.cpp
              sed -i '/ETH_P_/d; /RTMGRP_/d; /UDP_ENCAP/d; /AF_PACKET/d; /AF_NETLINK/d' libcore/luni/src/main/native/android_system_OsConstants.cpp
              sed -i '/RT_SCOPE_/d; /ST_MANDLOCK/d; /ST_NOATIME/d; /ST_NODEV/d; /ST_NODIRATIME/d; /ST_NOEXEC/d; /ST_RELATIME/d; /ST_SYNCHRONOUS/d' libcore/luni/src/main/native/android_system_OsConstants.cpp
              sed -i '/ARPHRD_LOOPBACK/d; /ENONET/d; /IP_MULTICAST_ALL/d; /MAP_POPULATE/d; /NETLINK_NETFILTER/d; /NETLINK_ROUTE/d' libcore/luni/src/main/native/android_system_OsConstants.cpp
              find libandroidfw libziparchive libcore/ojluni/src/main/native -type f -exec sed -i -E -e '/^#define F_SETLK/d' -e 's/off64_t/off_t/g' -e 's/flock64/flock/g' -e 's/dirent64/dirent/g' -e 's/F_SETLKW64/F_SETLKW/g' -e 's/F_SETLK64/F_SETLK/g' -e 's/android-base\/off_t\.h/android-base\/off64_t.h/g' -e 's/open64/open/g' -e 's/lseek64/lseek/g' -e 's/pread64/pread/g' -e 's/pwrite64/pwrite/g' -e 's/ftruncate64/ftruncate/g' -e 's/mmap64/mmap/g' -e 's/readdir64/readdir/g' -e 's/statvfs64/statvfs/g' -e 's/stat64/stat/g' -e 's/fstat64/fstat/g' -e 's/lstat64/lstat/g' {} +
              sed -i -e '/LinuxNativeDispatcher\.c/d' -e '/LinuxWatchService\.c/d' libcore/ojluni/src/main/native/openjdksub.mk
              sed -i 's|#include <wait.h>|#include <sys/wait.h>|' libcore/ojluni/src/main/native/UNIXProcess_md.c
          fi
          find build/core/combo -name "HOST_darwin-*.mk" -exec bash -c 'echo "HOST_GLOBAL_LDFLAGS += -Wl,-undefined,dynamic_lookup" >> "$1"' _ {} \;
          find . -type f \( -name "Android.mk" -o -name "Android.*.mk" \) -exec sed -i -e 's/-Wl,--export-dynamic//g' {} +
          # Strip ELF/GNU CFI & symbol attrs; mterp has its own ENTRY/END (not only arch/).
          find art/runtime/arch art/runtime/interpreter/mterp -type f -name "*.S" -exec sed -i -E \
            -e 's/\.fnstart//g' -e 's/\.fnend//g' \
            -e '/\.size/d' -e '/\.type/d' -e '/\.hidden/d' -e '/\.cfi_/d' {} +
          # Mach-O C symbols need a leading '_'; mirror x86_64 SYMBOL() for arm64 ENTRY/calls.
          # Darwin also forbids cbz/adr to non-local labels — rewrite those.
          python3 ${./darwin-asm-underscore.py}
          # Apple Clang has atomics built-in; GCC's -latomic is unavailable on Darwin.
          find art -type f \( -name "*.mk" -o -name "*.bp" \) -exec sed -i -E -e 's/-latomic//g' {} +
          # Darwin's clang assembler requires comma-delimited .macro args (GNU as accepts spaces).
          sed -i -E \
            -e 's/\.macro LOADREG counter size register return/.macro LOADREG counter, size, register, return/' \
            -e 's/\.macro ALLOC_OBJECT_TLAB_FAST_PATH_RESOLVED slowPathLabel isInitialized/.macro ALLOC_OBJECT_TLAB_FAST_PATH_RESOLVED slowPathLabel, isInitialized/' \
            -e 's/LOADREG ([^ ,]+) ([^ ,]+) ([^ ,]+) ([^ ,]+)/LOADREG \1, \2, \3, \4/g' \
            -e 's/:got:_ZN3art7Runtime9instance_E/__ZN3art7Runtime9instance_E@GOTPAGE/g' \
            -e 's/#:got_lo12:_ZN3art7Runtime9instance_E/__ZN3art7Runtime9instance_E@GOTPAGEOFF/g' \
            art/runtime/arch/arm64/quick_entrypoints_arm64.S
          # Darwin LP64: uintptr_t is unsigned long, uint64_t is unsigned long long.
          sed -i \
            -e 's/static constexpr uint64_t gZero/static constexpr uintptr_t gZero/' \
            -e 's/const_cast<uint64_t\*>(&gZero)/const_cast<uintptr_t*>(\&gZero)/' \
            -e 's/fprs_\[fp_reg\] = CalleeSaveAddress(frame, spill_pos, frame_info.FrameSizeInBytes());/fprs_[fp_reg] = reinterpret_cast<uint64_t*>(CalleeSaveAddress(frame, spill_pos, frame_info.FrameSizeInBytes()));/' \
            -e 's/DCHECK_NE(fprs_\[reg\], \&gZero)/DCHECK_NE(fprs_[reg], reinterpret_cast<const uint64_t*>(\&gZero))/' \
            art/runtime/arch/arm64/context_arm64.cc
          # Darwin has no execvpe(3); set environ via _NSGetEnviron then execvp.
          # Must not declare bare "extern char **environ" inside namespace art (→ art::environ).
          sed -i 's|#include "runtime.h"|#include "runtime.h"\n#include <crt_externs.h>|' \
            art/runtime/exec_utils.cc
          sed -i 's/execvpe(program, \&args\[0\], envp);/{ *_NSGetEnviron() = envp; execvp(program, \&args[0]); }/' \
            art/runtime/exec_utils.cc
          # bionic_dlerror() returns const char* (matches POSIX dlerror).
          sed -i 's/char\* bionic_dlerror_msg = bionic_dlerror();/const char* bionic_dlerror_msg = bionic_dlerror();/' \
            art/runtime/ti/agent.cc
          # Darwin has no <link.h>/dl_iterate_phdr; provide a no-op stub and skip CHECKs.
          cat > system/core/include/link.h <<'EOF_LINK_H'
      #ifndef ART_DARWIN_LINK_H_
      #define ART_DARWIN_LINK_H_
      #include <stddef.h>
      #include <stdint.h>
      #include <elf.h>
      #ifndef ElfW
      #if defined(__LP64__)
      #define ElfW(type) Elf64_ ## type
      #else
      #define ElfW(type) Elf32_ ## type
      #endif
      #endif
      struct dl_phdr_info {
        ElfW(Addr) dlpi_addr;
        const char *dlpi_name;
        const ElfW(Phdr) *dlpi_phdr;
        ElfW(Half) dlpi_phnum;
      };
      static inline int dl_iterate_phdr(int (*callback)(struct dl_phdr_info *, size_t, void *), void *data) {
        (void)callback;
        (void)data;
        return 0;
      }
      #endif
      EOF_LINK_H
          sed -i \
            -e '/CHECK(libjavacore_loaded_);/d' \
            -e '/CHECK(libnativehelper_loaded_);/d' \
            -e '/CHECK(libopenjdk_loaded_);/d' \
            art/runtime/jni/jni_internal.cc
          # Match JNIEnv MethodA hooks (jvalue*) — ART used const jvalue*, which clang rejects in the vtable.
          sed -i -E \
            -e 's/const jvalue\* vargs/jvalue* vargs/g' \
            -e 's/const jvalue\* args/jvalue* args/g' \
            art/runtime/jni/check_jni.cc art/runtime/jni/jni_internal.cc
          sed -i 's/findstring aarch64,$(ARCH)/findstring aarch64,$(ARCH))$(findstring arm64,$(ARCH)/' build/core/envsetup.mk
          sed -i 's/ifeq ($(HOST_OS),linux)/ifneq ($(HOST_OS),windows)/' libcore/NativeCode.mk libcore/JavaLibrary.mk build/core/host_dalvik_java_library.mk
          sed -i 's/ -lrt//g' libcore/NativeCode.mk
          sed -i 's/ifeq ($(HOST_OS),linux)/ifneq ($(HOST_OS),windows)/' external/okhttp/Android.mk
          sed -i 's/"libart\.so"/"libart.dylib"/' libnativehelper/JniInvocation.cpp
          echo "#!/bin/sh" > build/tools/check_radio_versions.py
          echo "exit 0" >> build/tools/check_radio_versions.py
          chmod +x build/tools/check_radio_versions.py
          echo -e "\nsystemimage:\n\t@echo Dummy systemimage\n" >> build/core/main.mk
          # Top Makefile hardcodes Linux out/ paths and .so; Darwin uses darwin-x86 + .dylib.
          # Broad s/libunwind// elsewhere leaves a bare "lib64/.so" install entry — drop it.
          sed -i \
            -e 's|out/host/linux-x86|out/host/darwin-x86|g' \
            -e 's|lib64/lib\([A-Za-z0-9_-]*\)\.so|lib64/lib\1.dylib|g' \
            -e '/lib64\/\.so/d' \
            -e '/lib64\/\.dylib/d' \
            Makefile
    '';

  # Host binaries use @loader_path/../lib64; install layout uses lib/art + natives.
  postInstall =
    (old.postInstall or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/lib64"
      for f in "$out"/lib/art/* "$out"/lib/java/dex/art/natives/*; do
        [ -e "$f" ] || continue
        ln -sfn "$f" "$out/lib64/$(basename "$f")"
      done
    '';

  postFixup =
    (old.postFixup or "")
    + lib.optionalString stdenv.hostPlatform.isDarwin ''
      for b in dalvikvm dex2oat; do
        if [ -x "$out/bin/$b" ]; then
          # libutils leaves native_handle_*/__android_log_* unbound (circular
          # libcutils↔libutils deps in Android.mk); preload providers for flat dyld.
          wrapProgram "$out/bin/$b" \
            --prefix DYLD_LIBRARY_PATH : "$out/lib" \
            --prefix DYLD_LIBRARY_PATH : "$out/lib/art" \
            --prefix DYLD_LIBRARY_PATH : "$out/lib/java/dex/art/natives" \
            --prefix DYLD_INSERT_LIBRARIES : "$out/lib/libcutils.dylib" \
            --prefix DYLD_INSERT_LIBRARIES : "$out/lib/liblog.dylib"
        fi
      done
    '';

  meta = (old.meta or { }) // {
    platforms = lib.platforms.all;
  };
})
