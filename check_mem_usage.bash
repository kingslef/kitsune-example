#!/usr/bin/env bash

################################################################################
# Small script for checking memory usage increase after update.
#
# Runs the example application few times and increasing the number of elements
# in the array each time by tenfold.
#
# Prints RSZ, VSZ and SZ increase between normal execution and after update has
# been running $SLEEP_AFTER_UPDATE seconds.
#
# Should produce something like this:
#
#    $ ./check_mem_usage.bash
#    1000, 8000
#    1000, 16000
#    RSZ     VSZ     SZ
#    328     136     34
#
#    10000, 80000
#    10000, 160000
#    RSZ     VSZ     SZ
#    1656    1484    371
#
#    100000, 800000
#    100000, 1600000
#    RSZ     VSZ     SZ
#    14112   14108   3527
#
#    1000000, 8000000
#    1000000, 16000000
#    RSZ     VSZ     SZ
#    140784  140636  35159
#
#    10000000, 80000000
#    10000000, 160000000
#    RSZ     VSZ     SZ
#    1406436 1406296 351574
#
################################################################################

APPLICATION="kitsune-example.so"
APPLICATION_V2="kitsune-v2.so"
SLEEP_AFTER_UPDATE="20"
DRIVER_PIDOF="driver"
DRIVER_START="${KITSUNE_PATH}/bin/driver"
APP_START="${DRIVER_START}"

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
    ${APP_START} "${APPLICATION}" >/dev/null &
    if [ "$?" -ne 0 ]
    then
        echo "Failed to start application ${APPLICATION}"
        exit 1
    fi
}

get_pid() {
    local pid=
    pid="$(pidof -s ${DRIVER_PIDOF})"
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

check_mem_usage_increase() {
    local pid="$1"

    local rsz_1=
    rsz_1="$(ps --no-headers --format=rsz "${pid}")"
    local vsz_1=
    vsz_1="$(ps --no-headers --format=vsz "${pid}")"
    local sz_1=
    sz_1="$(ps --no-headers --format=sz "${pid}")"

    update_app "$(pidof ${DRIVER_PIDOF})"
    sleep "${SLEEP_AFTER_UPDATE}"

    local rsz_2=
    rsz_2="$(ps --no-headers --format=rsz "${pid}")"
    local vsz_2=
    vsz_2="$(ps --no-headers --format=vsz "${pid}")"
    local sz_2=
    sz_2="$(ps --no-headers --format=sz "${pid}")"

    printf 'RSZ\tVSZ\tSZ\n'
    printf '%d\t%d\t%d\n' $(( rsz_2 - rsz_1 )) $(( vsz_2 - vsz_1 )) $(( sz_2 - sz_1 ))
}

pidof "${DRIVER_PIDOF}" >/dev/null 2>&1
if [ "$?" -eq 0 ]
then
    echo "${DRIVER_PIDOF} already running, kill it first"
    exit 1
fi

for (( n=1000; n<=10000000; n*=10 ))
do
    compile_app "${n}"

    start_app
    get_pid
    sleep 1

    check_mem_usage_increase "$(pidof ${DRIVER_PIDOF})"

    kill_app "$(pidof ${DRIVER_PIDOF})"

    echo
done
