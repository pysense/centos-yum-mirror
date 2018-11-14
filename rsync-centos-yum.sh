#!/bin/bash
# by 1057 (pysense@gmail.com)
set -o errexit
set -o nounset

include="centos.list"
DST=/data/mirrors/centos

cd $(dirname $(readlink -f ${BASH_SOURCE[0]}))
if [[ $# -ne 0 ]]; then
    if [[ -f "$1" ]]; then
        include="$1"
        shift
    fi
fi

mkdir -p $DST
rsync -avi --progress --delete --include-from="$include" --exclude="*" \
    --log-file=rsync-centos-yum.log \
    rsync://rsync.mirrors.ustc.edu.cn/centos $DST $*
