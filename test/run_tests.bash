#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

DIR=$(mktemp -d)
[[ $(bash ../scenario_1.bash --verify ${DIR}) == ${NOT_DONE} ]] && echo "T1_neg passed" || echo "T1_neg failed"
git init ${DIR} &> /dev/null
[[ $(bash ../scenario_1.bash --verify ${DIR}) == ${DONE} ]] && echo "T1_pos passed" || echo "T1_pos failed"
rm -rf ${DIR} &> /dev/null

bash ../scenario_2.bash &> /dev/null
DIR=$(cat repository.txt)
[[ $(bash ../scenario_2.bash --verify ${DIR}) == ${NOT_DONE} ]] && echo "T2_neg passed" || echo "T2_neg failed"
echo '*.txt' > ${DIR}/.gitignore
[[ $(bash ../scenario_2.bash --verify ${DIR}) == ${DONE} ]] && echo "T2_pos passed" || echo "T2_pos failed"
rm -rf ${DIR} &> /dev/null

\rm *.txt
