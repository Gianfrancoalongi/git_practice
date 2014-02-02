#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_remote_was_properly_added_and_fetched ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
        bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d GITPractice_Repo_XXXXXXXX)
    SCENARIO_REMOTE_GIT_REPO=$(mktemp -d GITPractice_REMOTE_REPO_XXXXXXXX)
    pushd ${SCENARIO_REMOTE_GIT_REPO}
    git init .
    touch {a,b,c,d}.txt 
    git add {a,b,c,d}.txt
    git commit -m 'initial commit'
    echo 'A is for algorithms' > a.txt && git commit -a -m 'Finished A'
    echo 'B is for bits' > b.txt && git commit -a -m 'Finished B'
    popd
    pushd ${SCENARIO_GIT_REPO}
    git init .
    touch {c,d}.txt
    git add {c,d}.txt
    git commit -m 'initial commit'
    echo 'C is for ciphers' > c.txt && git commit -a -m 'Finished C'
    echo 'D is for decryption' > d.txt && git commit -a -m 'Finished D'
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
    echo ${SCENARIO_REMOTE_GIT_REPO} > remote_repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Add the repository in ${SCENARIO_REMOTE_GIT_REPO} as a remote
and identify it using 'the_remote_repository' as the short name. 
Fetch the commits from the new remote. Do not merge the changes!

You can verify that this is properly done by visualizing
the git repository commits with 'gitk --all'
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.5 Git Basics - Working with Remotes
Git man page: git help remote
EOF
}

check_that_remote_was_properly_added_and_fetched() {
    pushd ${1} &> /dev/null
    FACIT_FILE_BRANCH=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE_BRANCH=$(mktemp /tmp/XXXXXXXX)
    FACIT_FILE_LOG=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE_LOG=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_FILE_BRANCH} <<EOF
* master
  remotes/the_remote_repository/master
EOF
    cat > ${FACIT_FILE_LOG} <<EOF
* Finished B
* Finished A
* initial commit
EOF
    git branch -a &> ${ACTUAL_FILE_BRANCH}
    git log master --graph --format='%s' &> ${ACTUAL_FILE_LOG}
    git log the_remote_repository/master --graph --format='%s' &> ${ACTUAL_FILE_LOG}

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
