#!/bin/bash

DRY_RUN=0
QUIET=0
DEPTH=2
THRESHOLD=30

while getopts nqd:t:h flag
do
    case "$flag" in
        n)  DRY_RUN=1
            ;;
        q)  QUIET=1
            ;;
        d)  DEPTH="$OPTARG"
            ;;
        t)  THRESHOLD="$OPTARG"
            ;;
        h)  echo "Usage: $0 [OPTIONS]"
            echo "  -n     -- dry run (don't actually delete)"
            echo "  -q     -- quiet mode"
            echo "  -d N   -- depth of search (default=2)"
            echo "  -t N   -- age threshold in days (default=30)"
            exit 0
            ;;
        *)  echo "Use '$0 -h' to get help"
            exit 1
            ;;
    esac
done

ALL_THEM=`find -maxdepth $DEPTH -name node_modules -type d`
NOW=`date +"%s"`
TOTAL=0

for NODE_MODS in $ALL_THEM
do
    MOD_TIME=`stat "$NODE_MODS" --printf="%Y"`
    SIZE=`du "$NODE_MODS" -c | tail -n1 | cut -f1`
    test $(( NOW - MOD_TIME > $THRESHOLD * 24 * 3600 )) = 1 && {
        test $QUIET = 0 && echo "$NODE_MODS - $SIZE"
        TOTAL=$(( TOTAL + SIZE ))
        test $DRY_RUN = 0 && rm -rf $NODE_MODS
    }
done

test $QUIET = 0 && {
    test $DRY_RUN = 0 && echo "Freed $TOTAL B"
    test $DRY_RUN = 1 && echo "Would free $TOTAL B"
}

exit 0
