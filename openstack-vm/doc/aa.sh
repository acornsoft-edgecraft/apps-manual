#!/bin/sh

TARGET="$1"

error_exit() {
        echo "error: ${1:-"unknown error"}" 1>&2
        exit 1
}

main() {
        if [ "$#" -ne 1 ]; then
                echo "vol-resize.sh volume"
                error_exit "Illegal number of parameters."
        fi

        echo "vol-resize.sh $TARGET"

        mv ${TARGET} ${TARGET}_bak

        qemu-img convert -c -p ${TARGET}_bak  -O qcow2 ${TARGET}

        echo "completed."
}

main "${@}"

# VM 안에서 dummy file로 disk를 꽉 체움.

$ dd if=/dev/zero of=./erase count=4 bs=1G
$ rm -f  /erase
$ rm -f  /erase2
...



/data/nfs/cinder

