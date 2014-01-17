#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_if_empty_git_repository_exists_at $2
    else
	generate_description_file
	generate_help_file
	show_scenario_text
    fi
}

show_scenario_text() {
cat <<EOF
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
       bash $0 --verify \${PATH_TO_NEW_GIT_REPOSITORY}
when you think you are done
=================================================================
You can always read 
    description.txt To know what you need to do
    help.txt        To get Pointers on what to read
=================================================================
EOF
}

generate_description_file() {
    cat > description.txt <<EOF
Set up an empty git repository somewhere on your system. 
This could be anywhere, for example in a new directory in /tmp.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
You can read Chapter 2.1 Git Basics - Getting a Git Repository
EOF
}

check_if_empty_git_repository_exists_at() {
    pushd $1 &> /dev/null
    STATUS=$(git status 2>/dev/null | grep "\# Initial commit")
    if [[ ${STATUS} == "# Initial commit" ]]
    then
	RES="Verified - you are done"
    else
	RES="No - you are not done"
    fi
    echo ${RES}
    popd &> /dev/null
}

main $@
