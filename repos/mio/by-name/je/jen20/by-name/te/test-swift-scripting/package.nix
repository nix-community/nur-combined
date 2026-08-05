{
  runCommand,
  swift,
}:

runCommand "test-swift-scripting"
  {
    nativeBuildInputs = [ swift ];
  }
  ''
    swift ${./script.swift} 10 | grep "Hello, 20.0"
    touch "$out"
  ''
