#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_we_have_fetched_and_merged_origin ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
	bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d /tmp/GITPractice_Repo_XXXXXXXX)
    SCENARIO_REMOTE_GIT_REPO=$(mktemp -d /tmp/GITPractice_REMOTE_REPO_XXXXXXXX)
    pushd ${SCENARIO_REMOTE_GIT_REPO}
    git init .
    touch {a,b,c,d}.txt 
    git add {a,b,c,d}.txt
    git commit -m 'initial commit'
    echo 'A is for algorithms' > a.txt && git commit -a -m 'Finished A'
    echo 'B is for bits' > b.txt && git commit -a -m 'Finished B'
    popd
    pushd /tmp
    git clone ${SCENARIO_REMOTE_GIT_REPO} ${SCENARIO_GIT_REPO}
    popd
    pushd ${SCENARIO_REMOTE_GIT_REPO}
    echo 'C is for ciphers' > c.txt && git commit -a -m 'Finished C'
    echo 'D is for decryption' > d.txt && git commit -a -m 'Finished D'
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Check that the repository is a clone of a remote repository.
Check that the origin/master branch has 2 additional commits that 
we don't see in the clone.

Get the local master branch up to par with the origin/remote
branch. 

You can verify that this is properly done by visualizing
the git repository commits with 'gitk --all'
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.5 Git Basics - Working with Remotes
Chapter 3.5 Git Branching - Remote Branches
EOF
}

check_that_we_have_fetched_and_merged_origin() {
    pushd ${1} &> /dev/null
    FACIT_FILE_BRANCH=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE_BRANCH=$(mktemp /tmp/XXXXXXXX)
    FACIT_FILE_LOG=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE_LOG=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_FILE_BRANCH} <<EOF
  origin/HEAD -> origin/master
  origin/master
EOF
    cat > ${FACIT_FILE_LOG} <<EOF
* Finished D
* Finished C
* Finished B
* Finished A
* initial commit
EOF
    git branch -r &> ${ACTUAL_FILE_BRANCH}
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
