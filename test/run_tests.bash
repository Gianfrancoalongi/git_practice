#!/bin/bash

DONE="Verified - you are done"
NOT_DONE="No - you are not done"

main() {

   scenario_1_tests

   for((x=2;x<=16;x++))
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
    DIR=$(mktemp -d)
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
    git checkout experimental &> /dev/null
    TO_CHERRY_PICK=$(git log --oneline --grep 'removing duplicate bigs - makes story too wordy' | cut -d ' ' -f 1)
    git checkout master &> /dev/null
    git cherry-pick ${TO_CHERRY_PICK} &> /dev/null
    cat > story.txt <<EOF
Once upon a time
  there was an old man living at the bottom of a big mountain.
At the top of the big mountain lived another old man.
Both old men had been living in their huts for over 30 years and
frequently went out to collect wood and herbs.
One day the man at the top of the big mountain dropped a piece
of firewood as he was walking along the edge. And the firewood
dropped all the way, from the top of the big mountain, down
to the bottom of the big mountain.
And so, a horse came walking down the mountain, and it came to be
that the firewood falling from the top, bouncing on all the rocks
and stones, on all the trees, and so finally hitting the door of
the old man at the bottom came to rest just as the horse passed
the door. The old man opened the door and asked who came to visit
him?
EOF
    git add story.txt  &> /dev/null
    git commit -m 'removing duplicate bigs - makes story too wordy' &> /dev/null
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
