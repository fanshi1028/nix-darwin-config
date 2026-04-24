{
  lib,
  stdenv,
  fetchurl,
}:
let
  pname = "swiftlm";
  version = "b543";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://github.com/SharpAI/SwiftLM/releases/download/${version}/SwiftLM-${version}-macos-arm64.tar.gz";
    hash = "sha256-kOuj3hS+4Q4pkD+DyieJTx+FaFuXY/ED3z+7ln0ZsaY=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    tar -xzf $src -C $out/bin/

    runHook postInstall
  '';

  meta = with lib; {
    description = "A blazingly fast, native Swift inference server for MLX models with OpenAI-compatible API";
    homepage = "https://github.com/SharpAI/SwiftLM";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    mainProgram = "SwiftLM";
  };
}
