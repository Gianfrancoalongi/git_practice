#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

main() {

   scenario_1_tests

   for((x=2;x<=19;x++))
   do
       if [[ ${x} -lt 10 ]]
       then
	   NUM=0${x}
       else
	   NUM=${x}
       fi
       bash ../scenario_${NUM}.bash &> /dev/null
       DIR=$(cat repository.txt)
       if [[ ${x} -gt 12 ]]
       then
	   REMOTE=$(cat remote_repository.txt)
       fi
       test_that_verification_fails_for_scenario ${NUM} ${DIR}
       pushd ${DIR} &> /dev/null
       solution_for_scenario_${NUM} ${DIR}
       popd &> /dev/null
       test_that_verification_passes_for_scenario ${NUM} ${DIR}
       rm -rf ${DIR} &> /dev/null       
   done
}

scenario_1_tests() {
    DIR=$(mktemp -d GIT_practice_XXXXXX)
    test_that_verification_fails_for_scenario 01 ${DIR}
    git init ${DIR} &> /dev/null
    test_that_verification_passes_for_scenario 01 ${DIR}
    rm -rf ${DIR} &> /dev/null
}

solution_for_scenario_02() {
    echo '*.txt' > ${1}/.gitignore
}

solution_for_scenario_03() {
    git config --local core.editor 'emacs -nw'
    git config --local merge.tool kdiff3
}

solution_for_scenario_04() {
    echo 'I made this.' >> file.txt
    git add file.txt &> /dev/null
    git commit -m "Added the file as requested." &> /dev/null
}

solution_for_scenario_05() {
    git reset HEAD b.txt &> /dev/null
}

solution_for_scenario_06() {
    git commit --amend -m 'Correct commit message.' &> /dev/null
}

solution_for_scenario_07() {
    git checkout a.txt
}

solution_for_scenario_08() {
    touch a.txt
    git add a.txt
    git commit -m 'Initial commit' &> /dev/null
    git checkout -b my_branch &> /dev/null
}

solution_for_scenario_09() {
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

solution_for_scenario_14() {
    git remote rename the_remote_repository other_repository &> /dev/null
}

solution_for_scenario_15() {
    git commit -a -m 'fixed the spelling errors' &> /dev/null
    git push the_remote_repository fixed_spelling &> /dev/null
}

solution_for_scenario_16() {
    git checkout more_cardio &> /dev/null
    MORE_RUNNING=$(git log --oneline --grep 'more running' | cut -d ' ' -f 1)
    git checkout more_strength &> /dev/null
    MORE_STRENGTH=$(git log --oneline --grep 'more strength' | cut -d ' ' -f 1)    
    git checkout master &> /dev/null
    git cherry-pick ${MORE_RUNNING} &> /dev/null
    git cherry-pick ${MORE_STRENGTH} &> /dev/null
}

solution_for_scenario_17() {
    git stash &> /dev/null
    git checkout master &> /dev/null
    git stash apply stash@{1} &> /dev/null
}

solution_for_scenario_18() {    
    GIT_SEQUENCE_EDITOR="sed -i '/^pick.*positive on 5.*/d'" \
    git rebase -i HEAD~3 &> /dev/null
}

solution_for_scenario_19() {
    FIRST=$(git log --format='%h' | tail -n 1)
    LAST=$(git log --format='%h' | head -n 1)
    git bisect start ${LAST} ${FIRST}
    BAD=$(git bisect run /tmp/test.bash | grep 'is the first bad' | cut -d ' ' -f 1)
    git checkout master
    GIT_SEQUENCE_EDITOR="sed -i '/pick .* fourth part/edit ${BAD} fourth part/'" \
	git rebase -i HEAD~2
    sed -i 's/beeches/beaches/' speech.txt
    git add speech.txt
    git commit -m 'fourth part'
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
