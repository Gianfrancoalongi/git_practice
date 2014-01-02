#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_branch_rebased_on_top_of_latest_changes ${2}
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
    touch {a,b}.txt
    git add {a,b}.txt &> /dev/null
    git commit -m 'Initial commit' &> /dev/null
    echo 'line one' >> a.txt && git commit -a -m 'A is modified' &> /dev/null
    git checkout -b working_branch &> /dev/null
    echo 'line one' >> b.txt && git commit -a -m 'B is modified' &> /dev/null
    echo 'line two' >> b.txt && git commit -a -m 'B is modified again' &> /dev/null
    git checkout master &> /dev/null
    echo 'line two' >> a.txt && git commit -a -m 'A is modified again' &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Rebase the branch 

    working_branch

on top of the latest changes in master.

You can verify that this is properly done by visualizing
the git repository commits with 

    gitk --all

You can find the repository location in the file named 
    repository.txt
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 3.6 Git Branching - Rebasing
EOF
}

check_that_branch_rebased_on_top_of_latest_changes() {
    pushd ${1} &> /dev/null
    FACIT_FILE_BRANCH=$(mktemp)
    ACTUAL_FILE_BRANCH=$(mktemp)
    FACIT_FILE_LOG=$(mktemp)
    ACTUAL_FILE_LOG=$(mktemp)
    cat > ${FACIT_FILE_BRANCH} <<EOF
  master
* working_branch
EOF
    cat > ${FACIT_FILE_LOG} <<EOF
* B is modified again
* B is modified
* A is modified again
* A is modified
* Initial commit
EOF
    git branch &> ${ACTUAL_FILE_BRANCH}
    git log --graph --format="%s" &> ${ACTUAL_FILE_LOG}

    diff -E -b ${FACIT_FILE_BRANCH} ${ACTUAL_FILE_BRANCH} &> /dev/null
    R1=$? 
    diff -E -b ${FACIT_FILE_LOG} ${ACTUAL_FILE_LOG} &> /dev/null
    R2=$?

    if [[ ${R1} == ${R2} && ${R2} == 0 ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    rm -f ${FACIT_FILE_BRANCH} \
	  ${ACTUAL_FILE_BRANCH} \
	  ${FACIT_FILE_LOG} \
	  ${ACTUAL_FILE_LOG} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@