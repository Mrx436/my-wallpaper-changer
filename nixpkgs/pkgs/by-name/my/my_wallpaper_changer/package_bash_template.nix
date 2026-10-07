{
  lib,
  makeWrapper,
  runCommand,
  # runtime deps (depend on script)
  bash,
  tree,
}:
let
  # Your external shell script.
  src = ./some-script.sh:
  binName = "some-script";
  deps = [
    bash
    tree
  ];
in
runCommand "${binName}"
  {
    nativeBuildInputs = [ makeWrapper ];
    meta = {
      mainProgram = "${binName}";
    };
  }
  ''
    mkdir -p $out/bin
    install -m +x ${src} $out/bin/${binName}
    wrapProgram $out/bin/${binName} \
      --prefix PATH : ${lib.makeBinPath deps}
  ''
