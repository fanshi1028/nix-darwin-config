{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_26,
  makeWrapper,
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

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ apple-sdk_26 ];

  preBuild = ''
    export MACOSX_DEPLOYMENT_TARGET=26
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/include
    cp -r metal $out/include/
    for bin in ds4 ds4-server ds4-bench ds4-eval ds4-agent; do
      install -m 755 "$bin" "$out/bin/"
      wrapProgram "$out/bin/$bin" \
        --set DS4_METAL_FLASH_ATTN_SOURCE "$out/include/metal/flash_attn.metal" \
        --set DS4_METAL_DENSE_SOURCE "$out/include/metal/dense.metal" \
        --set DS4_METAL_MOE_SOURCE "$out/include/metal/moe.metal" \
        --set DS4_METAL_DSV4_HC_SOURCE "$out/include/metal/dsv4_hc.metal" \
        --set DS4_METAL_UNARY_SOURCE "$out/include/metal/unary.metal" \
        --set DS4_METAL_DSV4_KV_SOURCE "$out/include/metal/dsv4_kv.metal" \
        --set DS4_METAL_DSV4_ROPE_SOURCE "$out/include/metal/dsv4_rope.metal"   \
        --set DS4_METAL_DSV4_MISC_SOURCE "$out/include/metal/dsv4_misc.metal"   \
        --set DS4_METAL_ARGSORT_SOURCE "$out/include/metal/argsort.metal" \
        --set DS4_METAL_CPY_SOURCE "$out/include/metal/cpy.metal" \
        --set DS4_METAL_CONCAT_SOURCE "$out/include/metal/concat.metal" \
        --set DS4_METAL_GET_ROWS_SOURCE "$out/include/metal/get_rows.metal" \
        --set DS4_METAL_SUM_ROWS_SOURCE "$out/include/metal/sum_rows.metal" \
        --set DS4_METAL_SOFTMAX_SOURCE "$out/include/metal/softmax.metal" \
        --set DS4_METAL_REPEAT_SOURCE "$out/include/metal/repeat.metal" \
        --set DS4_METAL_GLU_SOURCE "$out/include/metal/glu.metal" \
        --set DS4_METAL_NORM_SOURCE "$out/include/metal/norm.metal" \
        --set DS4_METAL_BIN_SOURCE "$out/include/metal/bin.metal" \
        --set DS4_METAL_SET_ROWS_SOURCE "$out/include/metal/set_rows.metal"
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
