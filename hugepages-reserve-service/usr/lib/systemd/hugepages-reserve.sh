#!/bin/sh
#
# Copyright 2024-2026 akam1o
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

nodes_path=/sys/devices/system/node
config_path=/etc/hugepages.conf

if [ ! -d "$nodes_path" ]; then
    echo "ERROR: $nodes_path does not exist"
    exit 1
fi

if [ ! -r "$config_path" ]; then
    echo "ERROR: $config_path does not exist or is not readable"
    exit 1
fi

reserve_pages_1g()
{
    if ! echo "$1" > "$nodes_path/$2/hugepages/hugepages-1048576kB/nr_hugepages"; then
        echo "ERROR: failed to reserve 1G hugepages on $2" >&2
        return 1
    fi
}

reserve_pages_2m()
{
    if ! echo "$1" > "$nodes_path/$2/hugepages/hugepages-2048kB/nr_hugepages"; then
        echo "ERROR: failed to reserve 2M hugepages on $2" >&2
        return 1
    fi
}

reservation_pids=
reservation_keys=
reservation_failed=0

while read -r line; do
    case "$line" in
        '#'*|'') continue ;;
    esac

    node=$(echo "$line" | awk '{print $1}')
    hugepage_size=$(echo "$line" | awk '{print $2}')
    hugepage_reserve_gb=$(echo "$line" | awk '{print $3}')

    # Validate node directory exists
    if [ ! -d "$nodes_path/$node" ]; then
        echo "WARNING: $nodes_path/$node does not exist, skipping"
        continue
    fi

    # Validate hugepage_reserve_gb is a positive integer
    case "$hugepage_reserve_gb" in
        ''|*[!0-9]*)
            echo "WARNING: invalid hugepage_reserve_gb '$hugepage_reserve_gb' for $node, skipping"
            continue
            ;;
    esac

    hugepage_size=$(echo "$hugepage_size" | tr '[:lower:]' '[:upper:]')

    case "$hugepage_size" in
        2M|1G)
            reservation_key="$node:$hugepage_size"
            case " $reservation_keys " in
                *" $reservation_key "*)
                    echo "ERROR: duplicate reservation for $node $hugepage_size, skipping"
                    reservation_failed=1
                    continue
                    ;;
            esac
            reservation_keys="$reservation_keys $reservation_key"
            ;;
    esac

    case "$hugepage_size" in
        2M)
            nr_hugepages=$((hugepage_reserve_gb * 512))
            echo "Reserving $nr_hugepages 2M hugepages on $node ($hugepage_reserve_gb GB)"
            reserve_pages_2m "$nr_hugepages" "$node" &
            reservation_pids="$reservation_pids $!"
            ;;
        1G)
            echo "Reserving $hugepage_reserve_gb 1G hugepages on $node ($hugepage_reserve_gb GB)"
            reserve_pages_1g "$hugepage_reserve_gb" "$node" &
            reservation_pids="$reservation_pids $!"
            ;;
        *)
            echo "WARNING: unsupported hugepage size '$hugepage_size' for $node, skipping"
            continue
            ;;
    esac
done < "$config_path"

# Wait for every reservation individually so that no write failure is lost.
for pid in $reservation_pids; do
    if ! wait "$pid"; then
        reservation_failed=1
    fi
done

exit "$reservation_failed"
