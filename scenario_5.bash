#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_b_is_not_staged_for_commit $2
    else
	setup_scenario
	generate_description_file
	generate_help_file
	show_scenario_text
    fi
}

show_scenario_text() {
    cat <<EOF
*****************************************************************
Scenario set up.
You can always read 
    description.txt to know what you need to do
    help.txt to get pointers on what to read in order to succeed
    repository.txt  to see where the scenario is created
*****************************************************************
Run this script as
       $0 --verify ${SCENARIO_GIT_REPO}
when you think you are done
*****************************************************************
EOF
echo "> description.txt"
cat description.txt
echo "*****************************************************************"
echo "> help.txt"
cat help.txt
echo "*****************************************************************"
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO} &> /dev/null
    git init . &> /dev/null
    touch {a,b,c}.txt &> /dev/null
    git add {a,b,c}.txt &> /dev/null
    git commit -m 'First commit' &> /dev/null
    for i in {a,b,c}.txt; do echo 'change' >> ${i}; done     
    git add {a,b,c}.txt &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Change so that b.txt is not staged for commit.
Only a.txt and c.txt should be staged for commit, so that
the command

    git commit -m 'Second commit'

should only include the changes in a.txt and c.txt

You can find the repository location in the file named 
    repository.txt
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.4 Git Basics - Undoing Things
 subchapter Unstaging a Staged File
EOF
}

check_that_b_is_not_staged_for_commit() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp)
    ACTUAL_FILE=$(mktemp)
    cat > ${FACIT_FILE} <<EOF
# On branch master
# Changes to be committed:
#   (use "git reset HEAD <file>..." to unstage)
#
#       modified:   a.txt
#       modified:   c.txt
#
# Changes not staged for commit:
#   (use "git add <file>..." to update what will be committed)
#   (use "git checkout -- <file>..." to discard changes in working directory)
#
#       modified:   b.txt
#
EOF
    git status &> ${ACTUAL_FILE}
    diff -E -b ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    if [[ $? == 0 ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    rm -f ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
