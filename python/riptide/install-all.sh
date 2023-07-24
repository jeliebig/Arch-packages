#!/bin/bash -e

if [ $# -lt 1 ]; then
    echo "Usage: $0 <pacman bin / AUR helper bin>"
    exit 2
fi

SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
PACMAN_BIN=$1
AUR_PACKAGES=('python-hosts' 'python-certauth')
PACKAGES=("${SCRIPT_DIR}/../configcrunch" "${SCRIPT_DIR}/lib" "${SCRIPT_DIR}/cli" "${SCRIPT_DIR}/proxy" "${SCRIPT_DIR}/engine-docker" "${SCRIPT_DIR}/db-mysql" "${SCRIPT_DIR}/plugin-php-xdebug")

not_installed=0
no_root=0

echo "Checking AUR dependencies..."

${PACMAN_BIN} -Qq "${AUR_PACKAGES[@]}" | grep "error" > /dev/null 2>&1 || not_installed=$?

if [ ${not_installed} -eq 0 ]; then
    ${PACMAN_BIN} -S | grep "root" > /dev/null 2>&1 || no_root=$?

    if [ ${no_root} -eq 0 ]; then
        sudo "${PACMAN_BIN}" -S "${AUR_PACKAGES[@]}"
    else
        ${PACMAN_BIN} -S "${AUR_PACKAGES[@]}"
    fi
fi

echo "Installing packages..."

for package in "${PACKAGES[@]}"; do
    pushd "${package}"
        makepkg -sic --noconfirm
    popd
done

echo "Done!"
