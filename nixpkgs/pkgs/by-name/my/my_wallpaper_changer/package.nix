{
  stdenv,
  fetchFromGitHub,
  pkgs,
}:

stdenv.mkDerivation {
  pname = "my-wallpaper-changer";
  version = "v0.1";

  src = fetchFromGitHub {
    owner = "Mrx436";
    repo = "my-wallpaper-changer";
    tag = "v0.1";
    sha256 = "sha256-hPYi8NFH1vcJVkA2LDkKpSvWB3vNVVdLOo/cSDnel7g=";
  };

  dontBuild = true;

  buildInputs = [ pkgs.bash ];

  installPhase = ''
      mkdir -p $out/bin
      cp $src/bash/my_first_sway_script.sh /$out/bin
    '';
}
