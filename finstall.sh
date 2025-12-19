#!/bin/bash
# Copyright KevinCrrl 2025: This program is distributed under the MIT License

set -e

if [ -z "$XDG_CACHE_HOME" ]; then
    FPATH="$HOME/.cache/finstall"
else
    FPATH="$XDG_CACHE_HOME/finstall"
fi

# Esto va despues de la verificacion de rutas para evitar que el script se termine en caso
# de que $XDG_CACHE_HOME no está definido.
set -u

OPTION="$1"
VERSION="1.0.0"

if [ ! -d "$FPATH" ]; then
    mkdir -p "$FPATH"
fi

error(){
    echo -e "\e[1;31m$1\e[m"
}

notice() {
    echo -e "\e[1;32m$1\e[m"
}

download_files(){
    URL="https://f-droid.org/repo/${1}_$2.apk"
    notice "Downloading APK..."
    curl -O "$URL"
    notice "Downloading ASC..."
    curl -O "$URL.asc"
}

download_metadata(){
    API="https://f-droid.org/api/v1/packages/$1"
    curl -s "$API" -o "metadata.json"
}

gpg_verify() {
    apk="$1"
    asc="$2"

    FINGERPRINT="37D2C98789D8311948394E3E41E7044E1DBA2E89"

    # Revisar si la llave no está importada
    if ! gpg --list-keys "$FINGERPRINT" &>/dev/null; then
        gpg --keyserver keyserver.ubuntu.com --recv-key "$FINGERPRINT"
    fi

    # Verifición de la firma
    if gpg --verify "$asc" "$apk"; then
        notice "Verified: $apk"
        return 0
    else
        error "Verification failed: $apk"
        return 1
    fi
}

gpg_install(){
    REINSTALL="${3-}"
    BASEFILE="${1}_$2.apk"
    # Continuar solo si la firma es correcta
    if gpg_verify "$BASEFILE" "$BASEFILE.asc"; then
        adb install --streaming "$REINSTALL" "$BASEFILE" || adb install "$REINSTALL" "$BASEFILE"
    fi
}

install(){
    local PDIR
    PDIR="$FPATH/$1"
    if [ ! -d "$PDIR" ]; then
        mkdir -p "$PDIR"
        cd "$PDIR"
        download_metadata "$1"
        local VERSIONCODE
        VERSIONCODE=$(cat metadata.json | jq ".suggestedVersionCode")
        download_files "$1" "$VERSIONCODE"
        gpg_install "$1" "$VERSIONCODE"
    else
        error "Package already installed, use 'reinstall'."
    fi
}

reinstall(){
    local PDIR
    PDIR="$FPATH/$1"
    cd "$PDIR"
    local VERSIONCODE
    VERSIONCODE=$(cat metadata.json | jq ".suggestedVersionCode")
    gpg_install "$1" "$VERSIONCODE" "-r"
}

uninstall(){
    DIR_TO_UNINSTALL="${FPATH:?}/$1"
    if [ -d "$DIR_TO_UNINSTALL" ]; then
        rm -rf "$DIR_TO_UNINSTALL"
        adb uninstall "$1"
    else
        error "Package not found."
    fi
}

simple_update(){
    TO_UPDATE="$FPATH/$1"
    if [ -d "$TO_UPDATE" ]; then
        cd "$TO_UPDATE"

        # Cargar version antigua en una variable
        OLD_VERSION=$(cat metadata.json | jq ".suggestedVersionCode")

        download_metadata "$1" # Descargar la nueva metadata

        # Almacenar la nueva version en otra variable
        NEW_VERSION=$(cat metadata.json | jq ".suggestedVersionCode")

        # Comparar las versiones para saber si la nueva es mayor que la antigua
        if [ "$NEW_VERSION" -gt "$OLD_VERSION" ]; then
            notice "Update found for $1"
            # Eliminar cache y descargar nuevos archivos
            rm ./*.apk*
            download_files "$1" "$NEW_VERSION"
            gpg_install "$1" "$NEW_VERSION" "-r"
        else
            echo "> No update found for $1"
        fi
    else
        error "Package not installed, use 'install'."
    fi
}

update_cli(){
    # verificar si $1 es ALL o un paquete
    if [[ "$1" == "ALL" ]]; then
        cd "$FPATH"
        for package in *; do
            simple_update "$package"
        done
    else
        simple_update "$1"
    fi
}

show_help(){
    cat << EOF
Free Install Version $VERSION:
USAGE: finstall.sh [OPTION] [PACKAGE]
Options:
    finstall.sh [install;uninstall;reinstall;update] PACKAGE

Update all packages: finstall.sh update ALL

Show version: finstall.sh version
Show this help: finstall.sh help
EOF
}

case "$OPTION" in
    install)    install "$2";;
    reinstall)  reinstall "$2";;
    uninstall)  uninstall "$2";;
    update)     update_cli "$2";;
    help)       show_help;;
    version)    echo $VERSION;;
    *)          error "Unknown option. Use help for available commands."
esac
