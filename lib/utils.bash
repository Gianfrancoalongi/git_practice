function get_current_repo 
{
   REPO_FILE=repository.txt
   if [ -e $REPO_FILE ]; then
      cat $REPO_FILE
   fi 
}
