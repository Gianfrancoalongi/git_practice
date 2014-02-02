#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_branch_was_3p_merged_and_deleted ${2}
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
    touch {a,b}.txt
    git add {a,b}.txt
    git commit -m 'Initial commit'
    git checkout -b diverged
    echo 'line one' >> a.txt && git commit -a -m 'A is modified'
    git checkout master
    echo 'line one' >> b.txt && git commit -a -m 'B is modified'
    git checkout diverged
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Merge the branch 'diverged' into the master branch so that the 
divergent histories are merged into a new commit.
You can verify that this is properly done by visualizing the git
repository commits with 'gitk --all'
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 3.2 Git Branching - Basic Branching and Merging
 subchapter Basic Merging
EOF
}

check_that_branch_was_3p_merged_and_deleted() {
    pushd ${1} &> /dev/null
    FACIT_FILE_BRANCH=$(mktemp XXXXXXXX)
    ACTUAL_FILE_BRANCH=$(mktemp XXXXXXXX)
    FACIT_FILE_LOG=$(mktemp XXXXXXXX)
    ACTUAL_FILE_LOG=$(mktemp XXXXXXXX)
    cat > ${FACIT_FILE_BRANCH} <<EOF
  diverged
* master
EOF
    cat > ${FACIT_FILE_LOG} <<EOF
*   Merge branch 'diverged'
|\\
| * A is modified
* | B is modified
|/
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
