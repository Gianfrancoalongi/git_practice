#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_b_is_not_staged_for_commit $2
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d GITPractice_XXXXXXXX)
    pushd ${SCENARIO_GIT_REPO}
    git init .
    touch {a,b,c}.txt
    git add {a,b,c}.txt
    git commit -m 'First commit'
    for i in {a,b,c}.txt; do echo 'change' >> ${i}; done     
    git add {a,b,c}.txt 
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Change so that b.txt is no longer staged for commit, but still
modified. Only a.txt and c.txt should be staged for commit.
You can see which files are staged for commit by the command
git status
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
    FACIT_FILE=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE=$(mktemp /tmp/XXXXXXXX)
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
