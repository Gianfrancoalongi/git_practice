#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_branch_was_created_and_switched_to ${2}
    else
	setup_scenario
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO} &> /dev/null
    git init . &> /dev/null
    touch b.txt 
    git add b.txt
    git commit -m 'Base commit' &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Create a branch called 'my_branch' and switch to this new branch.
The output of the command 'git branch' should show the new branch
'my_branch' as checked out (preceeded by an asterisk).
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 3.2 Git Branching - Basic Branching and Merging
EOF
}

check_that_branch_was_created_and_switched_to() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp)
    ACTUAL_FILE=$(mktemp)
    cat > ${FACIT_FILE} <<EOF
  master
* my_branch
EOF
    git branch &> ${ACTUAL_FILE}
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
