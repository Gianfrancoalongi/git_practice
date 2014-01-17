#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_file_is_properly_committed $2
    else
	setup_scenario
	generate_description_file
	generate_help_file
	show_scenario_text
    fi
}

show_scenario_text() {
    cat <<EOF
=================================================================
Your scenario GIT repository is in ${SCENARIO_GIT_REPO}
=================================================================
EOF
cat description.txt
cat <<EOF
=================================================================
Recommended reading in Pro Git            http://git-scm.com/book
EOF
cat help.txt
cat <<EOF
=================================================================
Run this script as
       bash $0 --verify ${SCENARIO_GIT_REPO}
when you think you are done
=================================================================
You can always read 
    description.txt To know what you need to do
    help.txt        To get Pointers on what to read
    repository.txt  To see where the scenario GIT repository is
=================================================================
EOF
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO} &> /dev/null
    git init . &> /dev/null
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Add a file called file.txt containing the text 'I made this!'
to the git repository, commit it with the exact commit message
'Added the file as requested.'
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 2.2 Git Basics - Recording Changes to the Repository
EOF
}


check_that_file_is_properly_committed() {
    pushd $1 &> /dev/null
    FILE=$(git log --name-only --pretty=oneline 2>/dev/null | tail -n 1)
    MSG=$(git log --name-only --pretty=oneline 2>/dev/null | head -n 1 | cut -d ' ' -f 2-)
    if [[ ${FILE} == "file.txt" && ${MSG} == "Added the file as requested." ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    echo ${RES}
    popd &> /dev/null
}

main $@
