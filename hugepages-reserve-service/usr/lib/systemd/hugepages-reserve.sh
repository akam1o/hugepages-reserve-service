#!/bin/sh

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
