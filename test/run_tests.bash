#!/bin/bash

DIR=$(mktemp -d)
[[ $(bash ../scenario_1.bash --verify ${DIR}) == "No - you are not done" ]] && echo "T1 passed" || echo "T1 failed"
git init ${DIR} &> /dev/null
[[ $(bash ../scenario_1.bash --verify ${DIR}) == "Verified - you are done" ]] && echo "T2 passed" || echo "T2 failed"
rm -rf ${DIR} &> /dev/null
