#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_a_has_no_modifications $2
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d XXXXXXXX)
    pushd ${SCENARIO_GIT_REPO}
    git init .
    touch {a,b,c}.txt
    git add {a,b,c}.txt
    git commit -m 'Initial commit'
    for i in {a,b,c}.txt; do echo 'changes' >> ${i};done
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Revert a.txt so that only b.txt and c.txt are marked as changed 
when issuing the command 'git status --short'
Do not edit the file a.txt manually.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.4 Git Basics - Undoing Things
 subchapter Unmodifying a Modified File
EOF
}

check_that_a_has_no_modifications() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp XXXXXXXX)
    ACTUAL_FILE=$(mktemp XXXXXXXX)
    cat > ${FACIT_FILE} <<EOF
 M b.txt
 M c.txt
EOF
    git status --short &> ${ACTUAL_FILE}
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
