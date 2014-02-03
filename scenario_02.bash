#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
      check_if_files_are_properly_ignored_at $2
    else
      setup_scenario &> /dev/null
      generate_description_file
      generate_help_file
      bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d /tmp/GITPractice_Repo_XXXXXXXX)
    pushd ${SCENARIO_GIT_REPO}
    for i in {1..100}; do touch ${i}.txt; done
    git init .
    popd
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Ensure that all *.txt files are properly ignored in the git repo.
Thus, when issuing the commang 'git status' you should not get
a listing of all the *.txt files.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.2 Git Basisc - Recording Changes to the Repository
subchapter Ignoring Files.
EOF
}

check_if_files_are_properly_ignored_at() {
    pushd ${1} &> /dev/null
    FACIT_FILE=$(mktemp /tmp/XXXXXXXX)
    ACTUAL_FILE=$(mktemp /tmp/XXXXXXXX)
    cat > ${FACIT_FILE} <<EOF
# On branch master
#
# Initial commit
#
# Untracked files:
#   (use "git add <file>..." to include in what will be committed)
#
#       .gitignore
nothing added to commit but untracked files present (use "git add" to track)
EOF
   git status &> ${ACTUAL_FILE}
   diff -E -b ${FACIT_FILE} ${ACTUAL_FILE} &>/dev/null
   if [[ $? == 0 ]]
   then
      RES="Verified - you are done"
   else
      RES="No - you are not done"
   fi
   rm ${FACIT_FILE} ${ACTUAL_FILE} &> /dev/null
   echo ${RES}
   popd &> /dev/null
}

main $@
