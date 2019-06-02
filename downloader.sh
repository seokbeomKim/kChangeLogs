#!/bin/bash
#
# NOTICE
# This script uses https://cdn.kernel.org/pub/linux/kernel/ by default.
# If you want to use other links to get change-log, please modify $SOURCE
#
SOURCE="http://cdn.kernel.org/pub/linux/kernel"

# PATHS
DIRECTORY_ROOT=$(pwd)
DIRECTORY_DOWNLOADS=${DIRECTORY_ROOT}/changelogs

wget -q -O- -H 'Accept-Encoding: gzip' ${SOURCE} | gzip -cdf > vlist

# wget $SOURCE -O vlist
VERSIONS=( $(cat vlist | grep 'href="v' | sed -e 's/^\(<a href=".*">\)\(.*\)\(\/<\/a>.*$\)/\2/g') )
NUMBER_OF_VERSIONS=${#VERSIONS[@]}
MINIMUM_VERSION=1.0
MAXIMUM_VERSION=5.1
KEYWORD=""

# Functions (Option handler)
function download () {
    # Download change-logs
    mkdir -pv ${DIRECTORY_DOWNLOADS}

    for version in ${VERSIONS[@]}; do
        TPATH=${DIRECTORY_DOWNLOADS}/${version}
        mkdir -pv ${TPATH}
        wget -q -O- -H 'Accept-Encoding: gzip' ${SOURCE}/${version} | gzip -cdf > ${TPATH}/filelist

        TFILELIST=( $(cat ${TPATH}/filelist | grep -i change | grep -v sign | sed -e 's/^\(.*"\)\(.*\)\(">.*\)/\2/g') )
        for file in ${TFILELIST[@]}; do
            wget -q -O- -H 'Accept-Encoding: gzip' ${SOURCE}/${version}/${file} | gzip -cdf > ${TPATH}/${file}
        done
    done
}

function help () {
    echo "Usage: $0 [-h(elp)] [-d(ownload)] [-v(ersion)] [-m(inimum version)] [-M(aximum version)]"
}

function search () {
    # Search function uses 'nrgrep'
    nrgrep $KEYWORD ${DIRECTORY_DOWNLOADS}/*/*
}

while getopts "dhk:vm:M:" o; do
    case "${o}" in
        h)
            help
            ;;
        d)
            download
            ;;
        v)
            MINIMUM_VERSION=${OPTARG}
            MAXIMUM_VERSION=${OPTARG}
            ;;
        m)
            MINIMUM_VERSION=${OPTARG}
            ;;
        M)
            MAXIMUM_VERSION=${OPTARG}
            ;;
        k)
            KEYWORD=${OPTARG}
            SEARCHING=true
    esac
done

if [ "$#" -eq 0 ]; then
    help
else
    if [ SEARCHING ]; then
        search
    fi
fi
