{
  lib,
  stdenv,
  fetchurl,
}:
let
  pname = "draw-things-cli";
  version = "v1.20260418.1";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/drawthingsai/draw-things-community/releases/download/${version}/${pname}";
    sha256 = "sha256-ehjta0rPG5ZnWiFI03wJFOKWF59pA9UpUVfACx4vHoQ=";
  };

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/bin
    install -m 755 $src $out/bin/${pname}
  '';

  meta = with lib; {
    description = "Draw Things CLI - local AI image generation on macOS";
    homepage = "https://github.com/drawthingsai/draw-things-community";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    maintainers = [ ];
  };
}
