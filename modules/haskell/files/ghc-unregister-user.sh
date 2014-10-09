#!/bin/bash
# Unregister all user GHC packages, respecting dependencies

for ((i=0; i<$(ghc-pkg list --user | wc -l); i++))
do
    for package in $(ghc-pkg list --user)
    do
	ghc-pkg unregister $(echo $package | sed -e "s/(\(.*\))/\1/g" -e "/\/.*/d")
    done
done
exit 0