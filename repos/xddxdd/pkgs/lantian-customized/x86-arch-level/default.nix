{
  lib,
  writeTextFile,
  gawk,
}:
writeTextFile rec {
  name = "x86-arch-level";
  derivationArgs.version = "1.0";
  executable = true;
  destination = "/bin/${name}";
  text = ''
    #!${gawk}/bin/awk -f

    BEGIN {
      while (!/flags/) if (getline < "/proc/cpuinfo" != 1) exit 1
      if (/lm/&&/cmov/&&/cx8/&&/fpu/&&/fxsr/&&/mmx/&&/syscall/&&/sse2/) level = 1
      if (level == 1 && /cx16/&&/lahf/&&/popcnt/&&/sse4_1/&&/sse4_2/&&/ssse3/) level = 2
      if (level == 2 && /avx/&&/avx2/&&/bmi1/&&/bmi2/&&/f16c/&&/fma/&&/abm/&&/movbe/&&/xsave/) level = 3
      if (level == 3 && /avx512f/&&/avx512bw/&&/avx512cd/&&/avx512dq/&&/avx512vl/) level = 4
      if (level > 0) { print "CPU supports x86-64-v" level; exit level + 1 }
      exit 1
    }
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Check x86 architecture level";
    homepage = "https://unix.stackexchange.com/a/631226";
    license = lib.licenses.free;
    mainProgram = name;
  };
}
