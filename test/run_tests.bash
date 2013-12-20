#!/bin/bash

DIR=$(mktemp -d)
[[ $(bash ../scenario_1.bash --verify ${DIR}) == "No - you are not done" ]] && echo "T1_neg passed" || echo "T1_neg failed"
git init ${DIR} &> /dev/null
[[ $(bash ../scenario_1.bash --verify ${DIR}) == "Verified - you are done" ]] && echo "T1_pos passed" || echo "T1_pos failed"
rm -rf ${DIR} &> /dev/null

bash ../scenario_2.bash &> /dev/null
DIR=$(cat repository.txt)
[[ $(bash ../scenario_2.bash --verify ${DIR}) == "No - you are not done" ]] && echo "T2_neg passed" || echo "T2_neg failed"
echo '*.txt' > ${DIR}/.gitignore
[[ $(bash ../scenario_2.bash --verify ${DIR}) == "Verified - you are done" ]] && echo "T2_pos passed" || echo "T2_pos failed"
rm -rf ${DIR} &> /dev/null


\rm *.txt
