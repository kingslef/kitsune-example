#!/usr/bin/env bash

APPLICATION="kitsune-example.so"
APPLICATION_V2="kitsune-v2.so"

if [ ! -d "${KITSUNE_PATH}" ]
then
    echo "Define KITSUNE_PATH=<kitsune-core/bin> before starting"
    exit 1
fi

compile_app() {
    local n_elements="$1"
    make clean >/dev/null 2>&1
    N_DATA_ELEMENTS="$n_elements" make >/dev/null 2>&1
}

start_app() {
    "${KITSUNE_PATH}"/bin/driver "${APPLICATION}" >/dev/null &
    if [ "$?" -ne 0 ]
    then
        echo "Failed to start application ${APPLICATION}"
        exit 1
    fi
}

get_pid() {
    local pid=
    pid="$(pidof -s driver)"
    if [ "$?" -ne 0 ]
    then
        echo "Couldn't get pid"
        exit 1
    fi
    return "${pid}"
}

update_app() {
    local pid="$1"

    "${KITSUNE_PATH}"/bin/doupd "${pid}" "${APPLICATION_V2}"
    if [ "$?" -ne 0 ]
    then
        echo "Failed to start update application ${APPLICATION_V2}"
        exit 1
    fi
}

kill_app() {
    local pid="$1"

    kill -SIGTERM "${pid}"
    if [ "$?" -ne 0 ]
    then
        echo "Failed to kill application"
        exit 1
    fi
}

check_mem() {
    local pid="$1"

    ps -o rsz,vsz,sz,pmem,cmd "${pid}"
    if [ "$?" -ne 0 ]
    then
        echo "Failed to check memory usage"
        exit 1
    fi
}

pidof driver >/dev/null 2>&1
if [ "$?" -eq 0 ]
then
    echo "driver already running, kill it first"
    exit 1
fi

for (( n=1000; n<=10000000; n*=10 ))
do
    compile_app "${n}"

    start_app

    get_pid

    sleep 1
    check_mem "$(pidof driver)"

    update_app "$(pidof driver)"
    sleep 5
    check_mem "$(pidof driver)"

    kill_app "$(pidof driver)"

    echo
done
