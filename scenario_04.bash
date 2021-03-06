#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_file_is_properly_committed $2
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
    git init .
    popd
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
http://git-scm.com/book/en/Git-Basics-Recording-Changes-to-the-Repository
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
