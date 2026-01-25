#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HANDYG_SRC="${HANDYG_SRC:-}"

if [[ -z "${HANDYG_SRC}" ]]; then
  if [[ -d "${ROOT_DIR}/../handyg/src" ]]; then
    HANDYG_SRC="${ROOT_DIR}/../handyg/src"
  fi
fi

if [[ -z "${HANDYG_SRC}" || ! -d "${HANDYG_SRC}" ]]; then
  echo "ERROR: handyG source directory not found."
  echo "Set HANDYG_SRC=/path/to/handyG/src (the folder containing globals.f90, gpl_module.f90, ...)."
  exit 1
fi

FC="${FC:-gfortran}"

BUILD_DIR="${ROOT_DIR}/deps/build/double"
PREFIX_DIR="${ROOT_DIR}/deps/usr"
LIB_DIR="${PREFIX_DIR}/lib"
WRAPPER_F90="${ROOT_DIR}/deps/binarybuilder/bundled/handyg_capi.f90"

mkdir -p "${BUILD_DIR}" "${LIB_DIR}"

FFLAGS=(-cpp -std=f2008 -O3 -ffree-line-length-0 -fPIC -J "${BUILD_DIR}" -I "${BUILD_DIR}")

echo "==> Building libhandyg from: ${HANDYG_SRC}"
echo "==> Using wrapper: ${WRAPPER_F90}"

for f in globals ieps utils shuffle maths_functions mpl_module gpl_module; do
  echo "==> compiling ${f}.f90"
  "${FC}" "${FFLAGS[@]}" -c "${HANDYG_SRC}/${f}.f90" -o "${BUILD_DIR}/${f}.o"
done

echo "==> compiling handyg_capi.f90"
"${FC}" "${FFLAGS[@]}" -c "${WRAPPER_F90}" -o "${BUILD_DIR}/handyg_capi.o"

uname_s="$(uname -s)"
if [[ "${uname_s}" == "Darwin" ]]; then
  out="${LIB_DIR}/libhandyg.dylib"
  echo "==> linking ${out}"
  "${FC}" -dynamiclib -o "${out}" "${BUILD_DIR}"/*.o
else
  out="${LIB_DIR}/libhandyg.so"
  echo "==> linking ${out}"
  "${FC}" -shared -o "${out}" "${BUILD_DIR}"/*.o
fi

echo "==> done: ${out}"

