#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

main() {

   scenario_1_tests

   for((x=2;x<=9;x++))
   do
       bash ../scenario_0${x}.bash &> /dev/null
       DIR=$(cat repository.txt)
       test_that_verification_fails_for_scenario 0${x} ${DIR}
       pushd ${DIR} &> /dev/null
       solution_for_scenario_${x} ${DIR}
       popd &> /dev/null
       test_that_verification_passes_for_scenario 0${x} ${DIR}
       rm -rf ${DIR} &> /dev/null
   done
   for((x=10;x<=13;x++))
   do
       bash ../scenario_${x}.bash &> /dev/null
       DIR=$(cat repository.txt)
       if [[ ${x} -gt 12 ]]
       then
	   REMOTE=$(cat remote_repository.txt)
       fi
       test_that_verification_fails_for_scenario ${x} ${DIR}
       pushd ${DIR} &> /dev/null
       solution_for_scenario_${x} ${DIR}
       popd &> /dev/null
       test_that_verification_passes_for_scenario ${x} ${DIR}
       rm -rf ${DIR} &> /dev/null
   done
}

scenario_1_tests() {
    DIR=$(mktemp -d)
    test_that_verification_fails_for_scenario 01 ${DIR}
    git init ${DIR} &> /dev/null
    test_that_verification_passes_for_scenario 01 ${DIR}
    rm -rf ${DIR} &> /dev/null
}

solution_for_scenario_2() {
    echo '*.txt' > ${1}/.gitignore
}

solution_for_scenario_3() {
    git config --local core.editor 'emacs -nw'
    git config --local merge.tool kdiff3
}

solution_for_scenario_4() {
    echo 'I made this.' >> file.txt
    git add file.txt &> /dev/null
    git commit -m "Added the file as requested." &> /dev/null
}

solution_for_scenario_5() {
    git reset HEAD b.txt &> /dev/null
}

solution_for_scenario_6() {
    git commit --amend -m 'Correct commit message.' &> /dev/null
}

solution_for_scenario_7() {
    git checkout a.txt
}

solution_for_scenario_8() {
    touch a.txt
    git add a.txt
    git commit -m 'Initial commit' &> /dev/null
    git checkout -b my_branch &> /dev/null
}

solution_for_scenario_9() {
    git checkout master &> /dev/null
    git merge ahead_of_master &> /dev/null
    git branch -D ahead_of_master &> /dev/null
}

solution_for_scenario_10() {
    git checkout master &> /dev/null
    git merge diverged &> /dev/null  
}

solution_for_scenario_11() {
    git checkout working_branch &> /dev/null
    git rebase master &> /dev/null
}

solution_for_scenario_12() {
    git fetch &> /dev/null
    git merge origin/master &> /dev/null
}

solution_for_scenario_13() {
    git remote add the_remote_repository ${REMOTE} &> /dev/null
    git fetch the_remote_repository &> /dev/null
}

test_that_verification_fails_for_scenario() {
    if [[ $(bash ../scenario_${1}.bash --verify ${2}) == ${NOT_DONE} ]] 
    then
    	echo "T${1}_neg passed"
    else 
    	echo "T${1}_neg failed"
    fi
}

test_that_verification_passes_for_scenario() {
    if [[ $(bash ../scenario_${1}.bash --verify ${2}) == ${DONE} ]]
    then
	echo "T${1}_pos passed" 
    else 
	echo "T${1}_pos failed"
    fi
}

main

\rm *.txt
