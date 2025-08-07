{
  stdenv,
  lib,
  source,
}:

stdenv.mkDerivation {
  inherit (source) pname version src;

  buildPhase = ''
    runHook preBuild

    echo "Building ptrace time hook programs..."

    # Build main hook program
    $CC -Wall -Wextra -g -o time-hook src/main.c

    # Build test programs  
    $CC -Wall -Wextra -g -o multi_time_test tests/multi_time_test.c
    $CC -Wall -Wextra -g -o minimal_test tests/minimal_test.c

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # Install main program
    install -D -m755 time-hook $out/bin/$pname

    runHook postInstall
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    echo "Running ptrace time hook tests..."

    # Test 1: Basic functionality test
    echo "Test 1: Verify programs work individually"
    ./minimal_test > original_output.txt
    echo "✅ Test program runs successfully"

    # Test 2: Hook functionality test  
    echo "Test 2: Verify hook intercepts and modifies time"
    timeout 10s ./time-hook --verbose ./minimal_test > hooked_output.txt 2>&1 || true

    if grep -q "Found time() syscall" hooked_output.txt && grep -q "Time: 0" hooked_output.txt; then
      echo "✅ Hook successfully intercepted and modified time() syscall"
    else
      echo "❌ Hook test failed"
      echo "Hook output:"
      cat hooked_output.txt
      exit 1
    fi

    # Test 3: Multiple time calls test
    echo "Test 3: Verify multiple time call handling"
    timeout 15s ./time-hook --verbose ./multi_time_test > multi_output.txt 2>&1 || true

    if grep -q "Call 1: time = 0" multi_output.txt && grep -q "Call 3: time = 0" multi_output.txt; then
      echo "✅ Hook successfully handled multiple time calls with consistent fixed value"
    else
      echo "❌ Multiple time calls test failed"
      echo "Multi-test output:"
      cat multi_output.txt
      exit 1
    fi

    echo "All tests passed! ✅"

    runHook postCheck
  '';

  meta = with lib; {
    description = "A ptrace-based tool to hook and modify time() syscalls in Linux programs";
    longDescription = ''
      This tool uses Linux ptrace to intercept time() system calls in target programs 
      and replace the returned time with a fixed value. It's useful for program analysis,
      security testing, and malware analysis in sandboxed environments.

      Features:
      - Intercepts time() syscalls and returns fixed time value (2022-01-01 00:00:00 UTC)  
      - Works with both statically and dynamically linked binaries
      - Real-time syscall modification
      - Defensive security tool for analysis purposes
    '';
    homepage = "https://github.com/wrvsrx/time-hook";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    maintainers = [ ];
  };
}
