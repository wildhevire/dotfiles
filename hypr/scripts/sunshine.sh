#!/bin/sh
ROOT="${PWD%/*}/"
CONFIG=$ROOT"config/sunshine/"
if [[ $1 == "on" ]]; then
    status="sunshine_on.conf"
else
    status="sunshine_off.conf"
fi
# echo "$ROOT/$status"
# cat "$CONFIG$status"
ln -sf $CONFIG$status $ROOT"sunshine.conf"
