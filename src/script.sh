#!/bin/bash
set +e

LINTER_NAME="prettier"
PRETTIER_PARAMS=()
PRETTIER_FILE_PATERN=()
PRETTIER_VERSION="${PRETTIER_VERSION:-latest}"
PRETTIER_CONFIG_FILE="${PRETTIER_CONFIG_FILE:-}"
PRETTIER_IGNORE_FILE="${PRETTIER_IGNORE_FILE:-}"

read -r -a PRETTIER_FILE_PATERN <<< "${FILE_PATTERN:-.}"

# Check if prettier is installed
if [[ ! -f "$(command -v prettier || true)" ]]; then
  echo "::group:: Installing prettier ..."
  npm install "prettier@${PRETTIER_VERSION}" --global
  echo "::endgroup::"
fi

# Check if config files exists
if [[ -n "${PRETTIER_CONFIG_FILE}" ]]; then
  if [[ ! -f "${PRETTIER_CONFIG_FILE}" ]]; then
    echo "::error title=${LINTER_NAME}::Prettier config file not found: ${PRETTIER_CONFIG_FILE}"
    exit 1
  else
    PRETTIER_PARAMS+=( "--config" "${PRETTIER_CONFIG_FILE}" )
  fi
fi

if [[ -n "${PRETTIER_IGNORE_FILE}" ]]; then
  if [[ ! -f "${PRETTIER_IGNORE_FILE}" ]]; then
    echo "::error title=${LINTER_NAME}::Prettier ignore file not found: ${PRETTIER_IGNORE_FILE}"
    exit 1
  else
    PRETTIER_PARAMS+=( "--ignore-path" "${PRETTIER_IGNORE_FILE}" )
  fi
fi

# Run prettier
echo "::group::📝 Running prettier ..."
prettier_output=$(prettier --list-different --ignore-unknown "${PRETTIER_PARAMS[@]}" "${PRETTIER_FILE_PATERN[@]}" 2>&1)
prettier_exit_code=$?

echo "${prettier_output}" | { grep -Ev "\[error\]" || true; } | while read -r line ; do
  echo "error: ${line}: File is not properly formatted"
done

echo "::endgroup::"
exit "${prettier_exit_code}"
