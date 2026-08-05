# Strengthened REPL smoke test from jen20 gist
# https://gist.github.com/jen20/3b797f020ee81dc564e768f1670ced90
# (also related: booxter/nixpkgs fix-swift-repl).
{
  runCommand,
  swift,
}:

runCommand "test-swift-repl"
  {
    nativeBuildInputs = [ swift ];
    sandboxProfile = ''
      (allow file-read (literal "/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Resources/debugserver"))
    '';
  }
  ''
    export LLDB_DEBUGSERVER_PATH=/Applications/Xcode.app/Contents/SharedFrameworks/LLDB.framework/Resources/debugserver
    # Each line must be a complete REPL entry: with non-interactive input, LLDB’s REPL
    # evaluates line by line and does not wait for braces to balance.
    cat <<EOF | swift repl > repl-output
      func say(message: String) { print("Saying: \(message)") }
      say(message: "Hello, Nixpkgs!")
      import Foundation
      let payload = try! JSONEncoder().encode([1, 2, 3])
      print("Payload: \(String(data: payload, encoding: .utf8)!)")
    EOF
    grep "Saying: Hello, Nixpkgs!" repl-output
    grep "Payload: \[1,2,3\]" repl-output
    touch "$out"
  ''
