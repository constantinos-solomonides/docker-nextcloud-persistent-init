#!/bin/bash -x

# DONE
# [x]. Create mysql and nextcloud setup functions
# [x]. Use shopt to define the init
# [x]. Default to no action
# [x]. Identify where files are stored for database and `rsync`' them
# TODO
# []. URGENT: Upgrade nextcloud version to latest
# []. Setup certificates
# []. Do configuration fixes recommended
# []. Connect with postfix

function init_mysql(){
    set -x
    DONE_FILE="${CONTAINER_BASE_DIRECTORY}/${SHARED_DIRECTORY}/mysql-${DONE_FILE_NAME}"
    [ -e "${DONE_FILE}" ]  && return 0
    sed -i -e '/datadir.*=/s/#//' /etc/mysql/mariadb.conf.d/50-server.cnf
    cat > /docker-entrypoint-initdb.d/${SQL_INIT_FILENAME} <<END
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
GRANT ALL PRIVILEGES on ${MYSQL_DATABASE}.* to '${MYSQL_USER}'@'%';
END
    cat /docker-entrypoint-initdb.d/${SQL_INIT_FILENAME}
    docker-entrypoint.sh mariadbd & sleep 20;

    for directory in $(sed -e 's/#/ /g' <<<${MYSQL_DIRECTORIES}); do
        echo "rsync-ing directory ${directory}"
        ls ${directory}
        target="${CONTAINER_BASE_DIRECTORY}/${MYSQL_BASE_DIRECTORY}/${directory}"
        mkdir -p ${target}
        rsync -avuP "/${directory}/" "${target}/"

    done
    touch "${DONE_FILE}"
}

function init_nextcloud(){

    DONE_FILE="${CONTAINER_BASE_DIRECTORY}/${SHARED_DIRECTORY}/nextcloud-${DONE_FILE_NAME}"
    [ -e "${DONE_FILE}" ]  && return 0
    echo MYSQL_USER: "${MYSQL_USER}"
    echo MYSQL_PASSWORD: "${MYSQL_PASSWORD}"
    echo MYSQL_DATABASE: "${MYSQL_DATABASE}"
    echo MYSQL_HOST: "${MYSQL_HOST}"
    /entrypoint.sh apache2-foreground & sleep 10
    for directory in $(sed -e 's/#/ /g' <<<${NEXTCLOUD_DIRECTORIES}); do
        echo "rsync-ing directory ${directory}"
        target="${CONTAINER_BASE_DIRECTORY}/${NEXTCLOUD_BASE_DIRECTORY}/${directory}"
        mkdir -p ${target}
        rsync -avuP "/${directory}/" "${target}/"
    done
    touch "${DONE_FILE}"
}

while getopts mn OPTARG; do
    case "${OPTARG}" in 
        m)
            init_mysql;
        ;;
        n) 
            init_nextcloud;
        ;;
        *)
            echo "No option ${OPTARG} available"
        ;;
    esac
done
