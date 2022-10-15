#!/bin/bash
MARIADB_VERSION=${MARIADB_VERSION:-}
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
END
    exit $1
}

function get_mariadb_version(){
    MARIADB_VERSION=$(
        docker run --rm -t ubuntu:jammy \
            bash -c 'apt-get update >/dev/null 2>&1; apt-cache madison mariadb-server | \
                        cut -d "|" -f 2 | \
                        sort -V'| \
                        tail -n 1
    )
}

while getopts hdnm: flag; do
    case "${flag}" in
        h) usage 0;;
        d) set -x;;
        n) export E=echo;;
        m) MARIADB_VERSION=${OPTARG};;
        *) usage 1;;
    esac
done
