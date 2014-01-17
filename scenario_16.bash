#!/bin/bash

main() {
    if [[ $1 == "--verify" ]] 
    then
	check_that_cherry_was_picked ${2}
    else
	setup_scenario &> /dev/null
	generate_description_file
	generate_help_file
        bash user_text.bash $0
    fi
}

setup_scenario() {
    SCENARIO_GIT_REPO=$(mktemp -d)
    pushd ${SCENARIO_GIT_REPO}
    git init . &> /dev/null
    cat > story.txt <<EOF
Once upon a time
  there was an old man living at the bottom of a big big mountain.
At the top of the big big mountain lived another old man.
Both old men had been living in their huts for over 30 years and 
frequently went out to collect wood and herbs. 
EOF
    git add story.txt
    git commit -m 'first draft of story'
    cat >> story.txt <<EOF
One day the man at the top of the big big mountain dropped a piece
of firewood as he was walking along the edge. And the firewood 
dropped all the way, from the top of the big big mountain, down
to the bottom of the big big mountain. 
EOF
    git commit -a -m 'the drop'
    git checkout -b experimental
    TMP=(mktemp)
    sed 's/big big/big/g' story.txt > ${TMP} && mv ${TMP} story.txt
    git commit -a -m 'removing duplicate bigs - makes story too wordy'
    TMP=(mktemp)
    sed 's/firewood/branch/g' story.txt > ${TMP} && mv ${TMP} story.txt
    git commit -a -m 'the old men collected wood instead'

    git checkout master
    cat >> story.txt <<EOF
And so, a horse came walking down the mountain, and it came to be 
that the firewood falling from the top, bouncing on all the rocks 
and stones, on all the trees, and so finally hitting the door of 
the old man at the bottom came to rest just as the horse passed
the door. The old man opened the door and asked who came to visit
him? 
EOF
    git commit -a -m 'the long face'
    popd &> /dev/null
    echo ${SCENARIO_GIT_REPO} > repository.txt
}

generate_description_file() {
    cat > description.txt <<EOF
Cherry pick the commit which removes duplicate bigs.
This commit is on the experimental branch with the commit
message 'removing duplicate bigs - make story too wordy'.
EOF
}

generate_help_file() {
    cat > help.txt <<EOF
Chapter 5.3 Distributed Git - Maintaining a Project
  paragraph 'Rebasing and Cherry Picking Workflows'
Git man pages: git help cherry-pick
EOF
}

check_that_cherry_was_picked() {
    pushd ${1} &> /dev/null
    # FACIT_FILE_MESSAGE=$(mktemp)
    # cat message.txt  > ${FACIT_FILE_MESSAGE}
    # FACIT_FILE_BRANCH=$(mktemp)
    # git branch  > ${FACIT_FILE_BRANCH}
    # popd &> /dev/null
    # pushd ${REMOTE} &> /dev/null
    # git checkout fixed_spelling &> /dev/null
    # ACTUAL_FILE_MESSAGE=$(mktemp)
    # cat message.txt > ${ACTUAL_FILE_MESSAGE}
    # ACTUAL_FILE_BRANCH=$(mktemp)    
    # git branch -a &> ${ACTUAL_FILE_BRANCH}
    # diff -E -b ${FACIT_FILE_MESSAGE} ${ACTUAL_FILE_MESSAGE} &> /dev/null
    # R1=$? 
    # diff -E -b ${FACIT_FILE_BRANCH} ${ACTUAL_FILE_BRANCH} &> /dev/null
    # R2=$?

    # if [[ ${R1} == ${R2} && ${R2} == 0 ]]
    # then
    # 	RES="Verified - you are done"
    # else
    # 	RES="No - you are not done"
    # fi
    # rm -f ${FACIT_FILE_BRANCH} \
    # 	  ${ACTUAL_FILE_BRANCH} \
    # 	  ${FACIT_FILE_MESSAGE} \
    # 	  ${ACTUAL_FILE_MESSAGE} &> /dev/null
    popd &> /dev/null
    echo ${RES}
}

main $@
