#!/bin/sh
#
# Copyright 2024-2025 akam1o
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

nodes_path=/sys/devices/system/node/
if [ ! -d $nodes_path ]; then
    echo "ERROR: $nodes_path does not exist"
    exit 1
fi

reserve_pages_1g()
{
    echo $1 > $nodes_path/$2/hugepages/hugepages-1048576kB/nr_hugepages
}

reserve_pages_2m()
{
    echo $1 > $nodes_path/$2/hugepages/hugepages-2048kB/nr_hugepages
}

cat /etc/hugepages.conf | while read line; do
    if echo $line | grep -e '^#' -e '^$' >/dev/null; then
        continue
    fi
    node=`echo $line | awk '{print $1}'`
    hugepage_size=`echo $line | awk '{print $2}'`
    hugepage_reserve_gb=`echo $line | awk '{print $3}'`

    hugepage_size=`echo $hugepage_size | tr '[:lower:]' '[:upper:]'`

    if [ $hugepage_size = "2M" ]; then
        nr_hugepages=`expr $hugepage_reserve_gb \* 512`
        reserve_pages_2m $nr_hugepages $node
    fi

    if [ $hugepage_size = "1G" ]; then
        reserve_pages_1g $hugepage_reserve_gb $node
    fi

done
