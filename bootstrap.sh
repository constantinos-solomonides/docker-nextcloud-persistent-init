#!/bin/bash -xu

export E=${E:-}

export NEXTCLOUD_ADMIN_USER="${NEXTCLOUD_ADMIN_USER:-nextclouddbadmin}"
MARIADB_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD:-}"
NEXTCLOUD_ADMIN_PASSWORD="${NEXTCLOUD_ADMIN_PASSWORD:-}"
export MYSQL_PASSWORD="${MYSQL_PASSWORD:-${NEXTCLOUD_ADMIN_PASSWORD}}"

export LOCAL_BASE_DIRECTORY=$(dirname $(realpath $0))
export CONTAINER_BASE_DIRECTORY="/media/backup"
export MOUNTS_DIRECTORY="mounts"
export MYSQL_BASE_DIRECTORY="mysql"
export NEXTCLOUD_BASE_DIRECTORY="nextcloud"
export SHARED_DIRECTORY="shared"
export NEXTCLOUD_FQDN="${NEXTCLOUD_FQDN:-$(hostname)}"
export SQL_INIT_FILENAME="${SQL_INIT_FILENAME:-mysql_init.sql}"
export MYSQL_DATABASE="nextcloud"
export MYSQL_USER="${MYSQL_USER:-${NEXTCLOUD_ADMIN_USER}}"
export MYSQL_HOST="database"



export NEXTCLOUD_DIRECTORIES=$(
    echo \
        "var/www/html/data" \
        "var/www/html" \
        "var/log/apache2" \
        "etc/apache2" \
        "etc/ssl/certs/nextcloud" \
    | sed -e "s/\s\+/#/g"
)
export MYSQL_DIRECTORIES=$(
    echo \
        "var/lib/mysql" \
        "var/log/mysql" \
        "etc/mysql" \
    | sed -e "s/\s\+/#/g"
)
export DONE_FILE_NAME="SETUP_COMPLETE"

NEXTCLOUD_LOCAL_BASE='${LOCAL_BASE_DIRECTORY}/${MOUNTS_DIRECTORY}/${NEXTCLOUD_BASE_DIRECTORY}'
MYSQL_LOCAL_BASE='${LOCAL_BASE_DIRECTORY}/${MOUNTS_DIRECTORY}/${MYSQL_BASE_DIRECTORY}'
SHARED_LOCAL_BASE='${LOCAL_BASE_DIRECTORY}/${MOUNTS_DIRECTORY}/${SHARED_DIRECTORY}'

function recreate_directories(){
    ${E} sudo rm -rf ${LOCAL_BASE_DIRECTORY}/${MOUNTS_DIRECTORY}/${MYSQL_BASE_DIRECTORY}/*
    ${E} sudo rm -rf ${LOCAL_BASE_DIRECTORY}/${MOUNTS_DIRECTORY}/${NEXTCLOUD_BASE_DIRECTORY}/*
    ${E} sudo rm -rf ${LOCAL_BASE_DIRECTORY}/${MOUNTS_DIRECTORY}/${SHARED_DIRECTORY}/*${DONE_FILE_NAME}

    for directory in $(sed -e 's/#/ /g' <<<${NEXTCLOUD_DIRECTORIES}); do
        mkdir -p ${LOCAL_BASE_DIRECTORY}/${MOUNTS_DIRECTORY}/${NEXTCLOUD_BASE_DIRECTORY}/${directory}
    done
    for directory in $(sed -e 's/#/ /g' <<<${MYSQL_DIRECTORIES}); do
        mkdir -p ${LOCAL_BASE_DIRECTORY}/${MOUNTS_DIRECTORY}/${MYSQL_BASE_DIRECTORY}/${directory}
    done

}



function output_nextcloud_data(){
    set +x
    echo "For nextcloud container"
    echo "======================="
    echo "  environment:"
    echo '    NEXTCLOUD_FQDN: "${NEXTCLOUD_FQDN}"'
    echo '    MARIADB_ROOT_PASSWORD: "${MARIADB_ROOT_PASSWORD}"'
    echo '    NEXTCLOUD_ADMIN_USER: "${NEXTCLOUD_ADMIN_USER}"'
    echo '    NEXTCLOUD_ADMIN_PASSWORD: "${NEXTCLOUD_ADMIN_PASSWORD}"'
    echo '    LOCAL_BASE_DIRECTORY: "${LOCAL_BASE_DIRECTORY}"'
    echo '    CONTAINER_BASE_DIRECTORY: "${CONTAINER_BASE_DIRECTORY}"'
    echo '    NEXTCLOUD_BASE_DIRECTORY: "${NEXTCLOUD_BASE_DIRECTORY}"'
    echo '    MOUNTS_DIRECTORY: "${MOUNTS_DIRECTORY}"'

    echo "  volumes:" 
    for directory in $(sed -e 's/#/ /g' <<<${NEXTCLOUD_DIRECTORIES}); do
        echo "    - \"${NEXTCLOUD_LOCAL_BASE}/${directory}:/${directory}\""
    done


    echo "For nextcloud_init container"
    echo "============================"
    echo "  environment:"
    echo '    NEXTCLOUD_FQDN: "any.seeker-odysseas.net"'
    echo '    MARIADB_ROOT_PASSWORD: "${MARIADB_ROOT_PASSWORD}"'
    echo '    LOCAL_BASE_DIRECTORY: "${LOCAL_BASE_DIRECTORY}"'
    echo '    CONTAINER_BASE_DIRECTORY: "${CONTAINER_BASE_DIRECTORY}"'
    echo '    NEXTCLOUD_BASE_DIRECTORY: "${NEXTCLOUD_BASE_DIRECTORY}"'
    echo '    MYSQL_USER: "${MYSQL_USER}"        '
    echo '    MYSQL_PASSWORD: "${MYSQL_PASSWORD}"'
    echo '    MYSQL_DATABASE: "${MYSQL_DATABASE}"'
    echo '    MYSQL_HOST: "${MYSQL_HOST}"        '
    echo '    MOUNTS_DIRECTORY: "${MOUNTS_DIRECTORY}"'
    echo '    SHARED_DIRECTORY: "${SHARED_DIRECTORY}"'
    echo '    DONE_FILE_NAME: "${DONE_FILE_NAME}"'
    echo '    NEXTCLOUD_DIRECTORIES: "${NEXTCLOUD_DIRECTORIES}"'

    echo "  volumes:" 
    NEXTCLOUD_REMOTE_BASE='${CONTAINER_BASE_DIRECTORY}/${NEXTCLOUD_REMOTE_BASE}'
    for directory in $(sed -e 's/#/ /g' <<<${NEXTCLOUD_DIRECTORIES}); do
        echo "    - \"${NEXTCLOUD_LOCAL_BASE}/${directory}:${NEXTCLOUD_REMOTE_BASE}/${directory}\""
    done
    echo "    - \"${SHARED_LOCAL_BASE}:\${CONTAINER_BASE_DIRECTORY}/\${SHARED_DIRECTORY}\""
}

function output_mysql_data(){
    echo "For mysql container"
    echo "==================="
    echo "  environment:"
    echo '    MARIADB_ROOT_PASSWORD: "${MARIADB_ROOT_PASSWORD}"'
    echo '    LOCAL_BASE_DIRECTORY: "${LOCAL_BASE_DIRECTORY}"'
    echo '    CONTAINER_BASE_DIRECTORY: "${CONTAINER_BASE_DIRECTORY}"'
    echo '    MYSQL_BASE_DIRECTORY: "${MYSQL_BASE_DIRECTORY}"'
    echo '    MOUNTS_DIRECTORY: "${MOUNTS_DIRECTORY}"'

    echo "  volumes:" 
    for directory in $(sed -e 's/#/ /g' <<<${MYSQL_DIRECTORIES}); do
        echo "    - \"${MYSQL_LOCAL_BASE}/${directory}:/${directory}\""
    done

    echo "For mysql_init container"
    echo "========================"
    echo "  environment:"
    echo '    MARIADB_ROOT_PASSWORD: "${MARIADB_ROOT_PASSWORD}"'
    echo '    NEXTCLOUD_ADMIN_USER: "${NEXTCLOUD_ADMIN_USER}"'
    echo '    NEXTCLOUD_ADMIN_PASSWORD: "${NEXTCLOUD_ADMIN_PASSWORD}"'
    echo '    LOCAL_BASE_DIRECTORY: "${LOCAL_BASE_DIRECTORY}"'
    echo '    CONTAINER_BASE_DIRECTORY: "${CONTAINER_BASE_DIRECTORY}"'
    echo '    MYSQL_BASE_DIRECTORY: "${MYSQL_BASE_DIRECTORY}"'
    echo '    MOUNTS_DIRECTORY: "${MOUNTS_DIRECTORY}"'
    echo '    SHARED_DIRECTORY: "${SHARED_DIRECTORY}"'
    echo '    DONE_FILE_NAME: "${DONE_FILE_NAME}"'
    echo '    MYSQL_DIRECTORIES: "${MYSQL_DIRECTORIES}"'
    echo '    MYSQL_USER: "${MYSQL_USER}"        '
    echo '    MYSQL_PASSWORD: "${MYSQL_PASSWORD}"'
    echo '    MYSQL_DATABASE: "${MYSQL_DATABASE}"'
    echo '    MYSQL_HOST: "${MYSQL_HOST}"        '
    echo '    SQL_INIT_FILENAME="${SQL_INIT_FILENAME}"'

    echo "  volumes:" 
    MYSQL_REMOTE_BASE='${CONTAINER_BASE_DIRECTORY}/${MYSQL_BASE_DIRECTORY}'
    for directory in $(sed -e 's/#/ /g' <<<${MYSQL_DIRECTORIES}); do
        echo "    - \"${MYSQL_LOCAL_BASE}/${directory}:${MYSQL_REMOTE_BASE}/${directory}\""
    done
    echo "    - \"${SHARED_LOCAL_BASE}:\${CONTAINER_BASE_DIRECTORY}/\${SHARED_DIRECTORY}\""

}

function run_init(){
    read -p "If you want to remove all stored data, type REMOVE: "
    if [ "$REPLY" != "REMOVE" ]; then
        return 1
    fi
    
    recreate_directories
    echo "Make sure the following folders are mounted appropriately, and the following variables set:"
    output_nextcloud_data
    output_mysql_data

    echo ""
}

case "${1}" in
    init)
        run_init
    ;;
    start)
        docker compose -f docker-compose.yml start
    ;;
    stop)
        docker compose -f docker-compose.yml stop
    ;;
    up)
        if [ -z "${MARIADB_ROOT_PASSWORD}" ]; then
            read -s -r -p "MARIADB_ROOT_PASSWORD: " MARIADB_ROOT_PASSWORD
            echo ""
        fi

        if [ -z "${NEXTCLOUD_ADMIN_PASSWORD}" ]; then
            read -s -r -p "NEXTCLOUD_ADMIN_PASSWORD: " NEXTCLOUD_ADMIN_PASSWORD
            echo ""
        fi

        if [ -z "${MYSQL_PASSWORD}" ]; then
            read -s -r -p "MYSQL_PASSWORD" MYSQL_PASSWORD
            echo ""
        fi

        export MARIADB_ROOT_PASSWORD
        export NEXTCLOUD_ADMIN_PASSWORD
        export MYSQL_PASSWORD

        docker compose -f docker-compose.yml up --remove-orphans
    ;;
    down)
        docker compose -f docker-compose.yml down
    ;;
    logs)
        docker compose -f docker-compose.yml logs "${2}"
    ;;
    exec)
        # shellcheck disable=SC2086,SC2068
        docker compose -f docker-compose.yml exec -ti ${@:2}
    ;;
    restart)
        docker compose -f docker-compose.yml restart "${2}"
    ;;
    reset)
        RESET=true $0 start
    ;;
    *)
        echo "Invalid option ${1}"
    ;;
esac
