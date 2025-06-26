#!/bin/bash

CORE_DIR="/root/services/wow/core"

pids=()
filter="$1"

update_repo() {
    local dir="$1"
    if [[ -d "$dir" && (-z "$filter" || "$dir" == *"$filter"*) ]]; then
        echo "updating $dir..."
        git -C "$dir" pull -r --autostash &
        pids+=($!)
    fi
}

update_repo $CORE_DIR
for dir in $CORE_DIR/modules/mod-*/; do
	update_repo $dir
done
for pid in "${pids[@]}"; do
	wait "$pid" || exit 1
done

echo "All repositories updated."

$CORE_DIR/acore.sh compiler 1
