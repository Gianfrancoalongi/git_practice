#!/bin/bash

main()
{
   print_welcome
   select option in start resume help quit; do
      case $option in 
         start)
            init_tutorial
            run_tutorial
         ;;
         resume)
            run_tutorial
         ;;
         help)
            print_help
            echo "--"
            print_welcome
         ;;
         quit)
            echo "-- git-tutorial --"
            break;
         ;;
      esac
   done
}

init_tutorial()
{
   echo "scenario_02.bash" > current_scenario.txt
   echo 0 > score.txt
   cat /dev/null > progress.txt
}

good_bye()
{
   echo "hej då!"
}

print_help()
{
   cat README.md
   cat <<EOF
===
This tutorial, will guide you through all the defined exercises...
EOF
}

print_welcome()
{
         cat <<EOF
Welcome to git-tutorial. From this menu you can start a new tutorial session,
resume an already started session, read and learn about this tutorial, or just
quit and come later.
EOF
}

get_current_scenario()
{
   if [ ! -e current_scenario.txt ]; then
      init_tutorial
   fi
   cat current_scenario.txt
}

set_current_scenario()
{
   echo ${1} > current_scenario.txt   
}

get_next_scenario()
{
   SCENARIO=$(get_current_scenario)
   MAXLEVEL=$(get_last_level)
   NUM=$(get_level_from_scenario $SCENARIO)
   NUM=$((($NUM % $MAXLEVEL) + 1))
   get_scenario_from_level $NUM 
}

get_previous_scenario()
{
   SCENARIO=$(get_current_scenario)
   NUM=$(get_level_from_scenario $SCENARIO)
   if [ $NUM -gt 1 ]; then
      NUM=$(($NUM - 1)) 
   else
      echo "You're already in the minimum level."
   fi
   get_scenario_from_level $NUM 
}

get_last_level()
{
   LAST=$(ls scenario_*.bash | tail -n 1)
   get_level_from_scenario $LAST 
}

get_level_from_scenario ()
{
   echo ${1} | sed 's/scenario_\([^\.]*\).bash/\1/'
}

get_scenario_from_level ()
{
   echo ${1} | awk '{ printf "scenario_%02d.bash\n", $1 }'
}

get_current_repo ()
{
   cat repository.txt
}

run_tutorial()
{
   echo -e "Running $(get_current_scenario) scenario-----\n"
   run_scenario $(get_current_scenario)

   echo "Well done. Now, what would you like to do:"
   select option in run-next-level run-previous-level show-current-level show-score list-progress repeat finish; do
      case $option in 
         run-next-level)
            nextLevel=$(get_next_scenario)
            set_current_scenario $nextLevel
            run_scenario $nextLevel
         ;;
         run-previous-level)
            previousLevel=$(get_previous_scenario)
            set_current_scenario $previousLevel
            run_scenario $previousLevel
         ;;
         repeat)
            echo "repeating level $(get_current_scenario)"
            run_scenario $(get_current_scenario)
         ;;
         finish)
            echo "Farewell traveler, till the time our paths encounter again."
            break
         ;;
         show-current-level)
            echo "You're currently at level $(get_current_scenario)"
         ;;
         show-score)
            show_score
         ;;
         list-progress)
            echo "You have completed $(wc -l progress.txt) scenarios out of $(get_last_level)"
         ;;
      esac
      echo "Select one of the following options:"
   done
}

run_scenario()
{
   POINTS=10
   # print some instructions
   cat <<EOF
Hi there, you're now executing in a separate shell process, and your current
working directory is the GIT repository automatically created for the current 
exercise. As soon as you have finished with the exercise, please type exit and
your work will be validated by the script.
==== ==== ==== ==== ==== ==== 
EOF
   # prepare the exercise repos
   prepare_exercise_repo ${1}

   # run shell for repo
   run_shell_sandbox 

   # verify the work
   continueWithTheLoop=1
   theCurrentRepository=$(get_current_repo)
   while test $continueWithTheLoop -ne 0; do
      if [[ $(bash ${1} --verify $theCurrentRepository) == "No - you are not done" ]]; then
         # User did not complete sucessfuly the exercise.
         echo "You did not complete the exercise correctly. Would you like to try again?"
         select option in use-the-same-repository create-a-brand-new-repository I-want-a-break; do
            case $option in
               use-the-same-repository)
                  POINTS=$(((POINTS - 1) % 10))
                  run_shell_sandbox
                  break;
               ;;
               create-a-brand-new-repository)
                  POINTS=$(((POINTS - 3) % 10))
                  prepare_exercise_repo ${1}
                  run_shell_sandbox
                  break;
               ;;
               I-want-a-break)
                  echo "Darn. You lost 2 points from your global score as a penalty."
                  SCORE=$(get_current_score)
                  SCORE=$(($SCORE - 2))
                  set_current_score $SCORE
                  continueWithTheLoop=0
                  break
               ;;
            esac
         done
      else
         # User did finish with the exercise
         echo "Congrats! You've earend $POINTS points!" 
         SCORE=$(get_current_score)
         #TODO: add some bonus if the guy is doing really well...
         SCORE=$(($SCORE + $POINTS))
         set_current_score $SCORE
         echo ${1} >> progress.txt
         continueWithTheLoop=0
         break
      fi
   done
}

prepare_exercise_repo()
{
   bash ${1}   
}

run_shell_sandbox()
{
   pushd $(get_current_repo) &> /dev/null
   bash 
   popd &> /dev/null
}

get_current_score()
{
   cat score.txt
}

set_current_score()
{
   echo ${1} > score.txt
}

show_score()
{
   SCORE=$(get_current_score)
   echo "Your current score is $SCORE."
   if [ $SCORE -gt 190 ]; then
      echo "I'm pretty sure you want to contribute to make this tutorial better."
   elif [ $SCORE -gt 150 ]; then
      echo "You're a GIT pro!, congrats!"
   elif [ $SCORE -gt 120 ]; then
      echo "Well done! Keep working this way :-)"
   elif [ $SCORE -gt 90 ]; then
      echo "Nice work!"
   elif [ $SCORE -ge 70 ]; then
      echo "Keep working this way."
   elif [ $SCORE -ge 50 ]; then
      echo "Consistency is key."
   elif [ $SCORE -ge 30 ]; then
      echo "Good consistency, keep it going."
   elif [ $SCORE -gt 10 ]; then
      echo "Good progress!"
   elif [ $SCORE -le 10 ]; then
      echo "Nice start."
   elif [ $SCORE -lt 0 ]; then
      echo "Failing is a essential part of learning. Don't give up, keep practicing."
   else
      echo "This is not unheard of."
   fi
}

## Action!
main
