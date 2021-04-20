{ makeSetupHook, brotli, fd }:
(makeSetupHook { name = "brotlify-setup-hook.sh"; deps = [ brotli fd ]; }) ./setup-hook.sh
