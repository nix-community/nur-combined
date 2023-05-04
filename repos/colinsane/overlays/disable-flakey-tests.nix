# disable tests for packages which flake.
# tests will fail for a variety of reasons:
# - they were coded with timeouts that aren't reliable under heavy load.
# - they assume a particular architecture (e.g. x86) whereas i compile on multiple archs.
# - they assume too much about their environment and fail under qemu.
#
(next: prev: {
  ell = prev.ell.overrideAttrs (_upstream: {
    # 2023/02/11
    # fixes "TEST FAILED in get_random_return_callback at unit/test-dbus-message-fds.c:278: !l_dbus_message_get_error(message, ((void *)0), ((void *)0))"
    # 2023/04/06
    # fixes "test-cipher: unit/test-cipher.c:102: test_aes_ctr: Assertion `!r' failed."
    # unclear *why* this test fails.
    doCheck = false;
  });
  # fish = prev.fish.overrideAttrs (_upstream: {
  #   # 2023/02/28
  #   # The following tests FAILED:
  #   #     177 - sigint.fish (Failed)
  #   #     241 - torn_escapes.py (Failed)
  #   doCheck = false;
  # });
  # gjs = prev.gjs.overrideAttrs (_upstream: {
  #   # 2023/01/30: one test times out. probably flakey test that only got built because i patched mesa.
  #   doCheck = false;
  # });
  # gssdp = prev.gssdp.overrideAttrs (_upstream: {
  #   # 2023/02/11
  #   # fixes "ERROR:../tests/test-regression.c:429:test_ggo_7: assertion failed (error == NULL): Failed to set multicast interfaceProtocol not available (gssdp-error, 1)"
  #   doCheck = false;
  # });
  # gupnp = prev.gupnp.overrideAttrs (_upstream: {
  #   # 2023/02/22
  #   # fixes "Bail out! ERROR:../tests/test-bugs.c:205:test_bgo_696762: assertion failed (error == NULL): Failed to set multicast interfaceProtocol not available (gssdp-erro>"
  #   doCheck = false;
  # });
  # json-glib = prev.json-glib.overrideAttrs (_upstream: {
  #   # 2023/02/11
  #   # fixes: "15/15 json-glib:docs / doc-check    TIMEOUT        30.52s   killed by signal 15 SIGTERM"
  #   doCheck = false;
  # });
  # lapack-reference = prev.lapack-reference.overrideAttrs (_upstream: {
  #   # 2023/02/11: test timeouts
  #   # > The following tests FAILED:
  #   # >       93 - LAPACK-xlintstz_ztest_in (Timeout)
  #   # >        98 - LAPACK-xeigtstz_svd_in (Timeout)
  #   # >          99 - LAPACK-xeigtstz_zec_in (Timeout)
  #   doCheck = false;
  # });
  # libadwaita = prev.libadwaita.overrideAttrs (_upstream: {
  #   # 2023/01/30: one test times out. probably flakey test that only got built because i patched mesa.
  #   doCheck = false;
  # });
  # libsecret = prev.libsecret.overrideAttrs (_upstream: {
  #   # 2023/01/30: one test times out. probably flakey test that only got built because i patched mesa.
  #   doCheck = false;
  # });
  # libuv = prev.libuv.overrideAttrs (_upstream: {
  #   # 2023/02/11
  #   # 2 tests fail:
  #   # - not ok 261 - tcp_bind6_error_addrinuse
  #   # - not ok 267 - tcp_bind_error_addrinuse_listen
  #   doCheck = false;
  # });
  libwacom = prev.libwacom.overrideAttrs (_upstream: {
    # 2023/03/30
    # "libwacom:all / pytest TIMEOUT"
    doCheck = false;
    mesonFlags = [ "-Dtests=disabled" ];
  });

  # llvmPackages_12 =
  #   let
  #     tools = prev.llvmPackages_12.tools.extend (self: super: {
  #       libllvm = super.libllvm.overrideAttrs (upstream: {
  #         # 2023/02/21: fix: "FAIL: LLVM-Unit :: ExecutionEngine/MCJIT/./MCJITTests/MCJITTest.return_global (2857 of 42084)"
  #         # - nix log /nix/store/6vydavlxh1gvs0vmrkcx9qp67g3h7kcz-llvm-12.0.1.drv
  #         # - wanted by sequoia, rav1e, rustc-1.66.1  (is this right?)
  #         doCheck = false;
  #         # upstream sets this with `rec`; TODO: have upstream refer to the final overrideAttrs version of the derivation instead of using rec.
  #         cmakeFlags = next.lib.remove "-DLLVM_BUILD_TESTS=ON" upstream.cmakeFlags;
  #       });
  #     });
  #   in
  #     # see <nixpkgs:pkgs/development/compilers/llvm/12/default.nix>
  #     # - we copy their strategy / attrset mutilation
  #     prev.llvmPackages_12 // { inherit tools; } // tools;

  # llvmPackages_14 =
  #   let
  #     tools = prev.llvmPackages_14.tools.extend (self: super: {
  #       libllvm = super.libllvm.overrideAttrs (upstream: {
  #         # 2023/02/21: fix: "FAIL: LLVM-Unit :: ExecutionEngine/MCJIT/./MCJITTests/MCJITMultipleModuleTest.two_module_global_variables_case (43769 of 46988)"
  #         # - nix log /nix/store/ib2yw6sajnhlmibxkrn7lj7chllbr85h-llvm-14.0.6.drv
  #         # - wanted by clang-11-12-LLVMgold-path, compiler-rt-libc-12.0.1, clang-wrapper-12.0.1  (is this right?)
  #         doCheck = false;
  #         # upstream sets this with `rec`; TODO: have upstream refer to the final overrideAttrs version of the derivation instead of using rec.
  #         cmakeFlags = next.lib.remove "-DLLVM_BUILD_TESTS=ON" upstream.cmakeFlags;
  #       });
  #     });
  #   in
  #     # see <nixpkgs:pkgs/development/compilers/llvm/14/default.nix>
  #     # - we copy their strategy / attrset mutilation
  #     prev.llvmPackages_14 // { inherit tools; } // tools;

  # llvmPackages_15 =
  #   let
  #     tools = prev.llvmPackages_15.tools.extend (self: super: {
  #       libllvm = super.libllvm.override {
  #         # 2023/02/21: fix: "FAIL: LLVM-Unit :: ExecutionEngine/MCJIT/./MCJITTests/..."
  #         # llvm15 passes doCheck as a call arg, so we don't need to set cmakeFlags explicitly as in previous versions
  #         doCheck = false;
  #       };
  #     });
  #   in
  #     prev.llvmPackages_15 // { inherit tools; } // tools;

  # modemmanager = prev.modemmanager.overrideAttrs (_upstream: {
  #   # 2023/02/25
  #   # "ERROR:test-modem-helpers.c:257:test_cmgl_response: assertion failed: (list != NULL)"
  #   doCheck = false;
  #   doInstallCheck = false;  # tests are run during install check??
  # });

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (py-next: py-prev: {
      # ipython = py-prev.ipython.overridePythonAttrs (upstream: {
      #   # > FAILED IPython/core/tests/test_debugger.py::test_xmode_skip - pexpect.exceptions.TIMEOUT: Timeout exceeded.
      #   # > FAILED IPython/core/tests/test_debugger.py::test_decorator_skip - pexpect.exceptions.TIMEOUT: Timeout exceeded.
      #   # > FAILED IPython/core/tests/test_debugger.py::test_decorator_skip_disabled - pexpect.exceptions.TIMEOUT: Timeout exceeded.
      #   # > FAILED IPython/core/tests/test_debugger.py::test_decorator_skip_with_breakpoint - pexpect.exceptions.TIMEOUT: Timeout exceeded.
      #   # > FAILED IPython/core/tests/test_debugger.py::test_where_erase_value - pexpect.exceptions.TIMEOUT: Timeout exceeded.
      #   # > FAILED IPython/terminal/tests/test_debug_magic.py::test_debug_magic_passes_through_generators - pexpect.exceptions.TIMEOUT: Timeout exceeded.
      #   # > FAILED IPython/terminal/tests/test_embed.py::test_nest_embed - pexpect.exceptions.TIMEOUT: Timeout exceeded.
      #   disabledTestPaths = upstream.disabledTestPaths or [] ++ [
      #     "IPython/core/tests/test_debugger.py"
      #     "IPython/terminal/tests/test_debug_magic.py"
      #     "IPython/terminal/tests/test_embed.py"
      #   ];
      # });
      pyarrow = py-prev.pyarrow.overridePythonAttrs (upstream: {
        # 2023/04/02
        # disabledTests = upstream.disabledTests ++ [ "test_generic_options" ];
        disabledTestPaths = upstream.disabledTestPaths or [] ++ [
          "pyarrow/tests/test_flight.py"
        ];
      });
      # pytest-xdist = py-prev.pytest-xdist.overridePythonAttrs (upstream: {
      #   # 2023/02/19
      #   # 4 tests fail:
      #   # - FAILED: testing/test_remote.py::TestWorkInteractor::* - execnet.gateway_base.TimeoutError: no item after 10.0 seconds
      #   # doCheck = false;
      #   disabledTestPaths = upstream.disabledTestPaths or [] ++ [
      #     "testing/test_remote.py"
      #   ];
      #   # disabledTests = upstream.disabledTests or [] ++ [
      #   #   "test_basic_collect_and_runtests"
      #   #   "test_remote_collect_fail"
      #   #   "test_remote_collect_skip"
      #   #   "test_runtests_all"
      #   # ];
      # });
      # twisted = py-prev.twisted.overridePythonAttrs (upstream: {
      #   # 2023/02/25
      #   # ```
      #   # [ERROR]
      #   # Traceback (most recent call last):
      #   #   File "/nix/store/dcnsxrn8rsfk1dghah7md5glbbnfysq3-python3.10-twisted-22.10.0/lib/python3.10/site-packages/twisted/test/test_udp.py", line 645, in test_interface
      #   #     self.assertEqual(self.client.transport.getOutgoingInterface(), "0.0.0.0")
      #   #   File "/nix/store/dcnsxrn8rsfk1dghah7md5glbbnfysq3-python3.10-twisted-22.10.0/lib/python3.10/site-packages/twisted/internet/udp.py", line 449, in getOutgoingInterface
      #   #     i = self.socket.getsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_IF)
      #   # builtins.OSError: [Errno 92] Protocol not available
      #   #
      #   # twisted.test.test_udp.MulticastTests.test_interface
      #   # ```
      #   postPatch = upstream.postPatch + ''
      #     echo 'MulticastTests.test_interface.skip = "Protocol not available"'>> src/twisted/test/test_udp.py
      #   '';
      # });
    })
  ];

  # strp = prev.srtp.overrideAttrs (_upstream: {
  #   # 2023/02/11
  #   # roc_driver test times out after 30s
  #   doCheck = false;
  # });
  tracker = prev.tracker.overrideAttrs (_upstream: {
    # 2023/02/22
    # "27/37 tracker:core / service                          TIMEOUT         60.37s   killed by signal 15 SIGTERM"
    doCheck = false;
  });
  # udisks2 = prev.udisks2.overrideAttrs (_upstream: {
  #   # 2023/02/25
  #   # "udisks-test:ERROR:test.c:61:on_completed_expect_failure: assertion failed (message == expected_message): ("Command-line `./udisks-test-helper 4' was signaled with signal SIGSEGV (11):\nstdout: `OK, deliberately causing a segfault\n'\nstderr: `qemu: uncaught target signal 11 (Segmentation fault) - core dumped\n'" == "Command-line `./udisks-test-helper 4' was signaled with signal SIGSEGV (11): OK, deliberately causing a segfault\n")"
  #   doCheck = false;
  # });
  # upower = prev.upower.overrideAttrs (_upstream: {
  #   # 2023/02/25
  #   # "Tests.test_battery_state_guessing                          TIMEOUT        60.80s   killed by signal 15 SIGTERM"
  #   doCheck = false;
  # });
})
