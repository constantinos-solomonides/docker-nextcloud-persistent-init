#!/bin/bash
set -u
MARIADB_VERSION=${MARIADB_VERSION:-}
HOST_BASE=${HOST_BASE:-/var}
CONTAINER_BASE=${CONTAINER_BASE:-}
REQUIRED_TOOLS=(
    ${REQUIRED_TOOLS[@]:-}
    docker
    docker-compose
)
E=${E:-}


function usage(){
    cat 1>&2 <<END
    $(basename ${0})
    Bash script to initialise the nextcloud setup. It will build a mariadb container,
    create a directory structure on the host and copy files from within the containers in
    the host directories for persistency.

    Use:
    ${0} [ -h | [-m MARIADB_VERSION]]
    Option  METAVAR             Usage
    -h      -                   This help message
    -d      -                   Debug mode on
    -n      -                   Dry-Run mode on
    -m      MARIADB_VERSION     The MariaDB version to use
    -b      HOST_BASE           The base directory for the ones to mount on the host
    -B      CONTAINER_BASE      The base directory for mounting in containers
END
    exit $1
}

function create_host_directory_hierarchy(){
    mkdir -p ${HOST_BASE}/nextcloud/data
    mkdir -p ${HOST_BASE}/nextcloud/logs/database
    mkdir -p ${HOST_BASE}/nextcloud/logs/nextcloud
    mkdir -p ${HOST_BASE}/nextcloud/settings/certificates/nextcloud/
    mkdir -p ${HOST_BASE}/nextcloud/settings/db
    mkdir -p ${HOST_BASE}/nextcloud/settings/etc/apache2
    mkdir -p ${HOST_BASE}/nextcloud/settings/etc/mysql
    mkdir -p ${HOST_BASE}/nextcloud/settings/html
}

function verify_tools(){
    # Verify that all necessary tools are installed
    return_value=0
    for tool in ${REQUIRED_TOOLS[@]}; do
        command -v ${tool} || { echo 1>&2 "Tool ${tool} not found" ; return_value=1; }
    done
    return ${return_value}
}

function build_containers(){
    docker-compose build
}

function run_containers_to_copy_data(){
    # TODO
}
function stop_containers(){
    # TODO
}

function get_mariadb_version(){
    # Only run this if MARIA_DB version is unset
    [ -z "${MARIADB_VERSION}" ] || return
    MARIADB_VERSION=$(
        docker run --rm -t ubuntu:jammy \
            bash -c 'apt-get update >/dev/null 2>&1; apt-cache madison mariadb-server | \
                        cut -d "|" -f 2 | \
                        sort -V'| \
                        tail -n 1
    )
}

while getopts hdnm:b:B: flag; do
    case "${flag}" in
        h) usage 0;;
        d) set -x;;
        n) export E=echo;;
        m) MARIADB_VERSION=${OPTARG};;
        b) HOST_BASE=${OPTARG};;
        B) CONTAINER_BASE=${OPTARG};;
        *) usage 1;;
    esac
done

verify_tools || exit 1
get_mariadb_version
build_containers
run_containers_to_copy_data
stop_containers
