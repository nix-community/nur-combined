{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "exercisediary";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "aceberg";
    repo = "ExerciseDiary";
    tag = finalAttrs.version;
    hash = "sha256-ekGluDuBF4Zb/XTxLRdztVg447x13uo24nNTBuVSfj8=";
  };

  vendorHash = "sha256-VKY5cvcjGfjOWa+GnMwdPOfTPOiwoXy0LB7kVD9l4kw=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Workout diary with GitHub-style year visualization";
    homepage = "https://github.com/aceberg/ExerciseDiary";
    license = lib.licenses.mit;
    mainProgram = "ExerciseDiary";
    maintainers = [ lib.maintainers.sikmir ];
  };
})
