{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_26,
}:

stdenv.mkDerivation {
  pname = "ds4";
  version = "2026-06-17";

  src = fetchFromGitHub {
    owner = "antirez";
    repo = "ds4";
    rev = "80ebbc396aee40eedc1d829222f3362d10fa4c6c";
    sha256 = "sha256-Ieuc72GHZs20ModQfnvI5Me31n4Pj+WFYtsuqaKJceo=";
  };

  buildInputs = [ apple-sdk_26 ];

  preBuild = ''
    export MACOSX_DEPLOYMENT_TARGET=26
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    for bin in ds4 ds4-server ds4-bench ds4-eval ds4-agent; do
      install -m 755 "$bin" "$out/bin/"
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "ds4 - A fast LLM inference engine with Metal GPU support";
    homepage = "https://github.com/antirez/ds4";
    license = licenses.mit;
    platforms = [ "aarch64-darwin" ];
    maintainers = [ ];
  };
}
