#!/bin/bash
# Unregister all user GHC packages, respecting dependencies

for ((i=0; i<$(ghc-pkg list --user | wc -l); i++))
do
    for package in $(ghc-pkg list --user | sed -e "s/(\(.*\))/\1/g" -e "/\/.*/d" -e "/no packages/d")
    do
	ghc-pkg unregister $package
    done
done
exit 0