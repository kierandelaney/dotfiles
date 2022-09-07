# PRODUCTION
alias livedeploy='knife ssh "chef_environment:production" "cd /data/www/drupal8/ ; git pull" --ssh-user innkeeper --attribute ipaddress'

# UAT
alias udeploy='knife ssh "chef_environment:uat" "cd /data/www/drupal8/ ; git pull" --ssh-user innkeeper --attribute ipaddress'

# UTILITY
alias utilitydeploy='knife ssh "name:utilit*" "cd /data/www/drupal8/ ; git pull" --ssh-user innkeeper --attribute ipaddress'

# DEPLOY ALL!
alias deploy='udeploy && livedeploy && utilitydeploy'

# other chefs
alias chefall='knife ssh "name:*" "sudo chef-client" --ssh-user innkeeper --attribute ipaddress'
alias restartsuper='knife ssh "recipes:*supervisor*" "sudo supervisorctl reload" --ssh-user innkeeper --attribute ipaddress'

# Make a branch from current live, push to github and track
function makebranch() {
  if [[ $# -eq 1 ]] ; then
    exists=`git show-ref refs/heads/$1`
    git checkout live;
    git pull;
    if [ -n "$exists" ]; then
      echo "A branch called '$1' already exists";
    else
      thisremote=`git remote`;
      git checkout -b $1;
      git push -u $thisremote $1;
    fi;
  else
    echo "I need a branch please.";
  fi;
}

# Merge given branch into an up to date uat and push both branches to github, deploy uat after
function mergeuat() {
  if [[ $# -eq 1 ]] ; then
    exists=`git show-ref refs/heads/$1`
    if [ -n "$exists" ]; then
      thisbranch=`git rev-parse --abbrev-ref HEAD`;
      thisremote=`git remote`;
      echo "Current Branch: $thisbranch";
      git checkout uat;
      git pull;
      git merge $1 --no-edit;
      git push $thisremote uat $1;
      udeploy;
      git checkout $thisbranch;
    else
      echo "A branch called '$1' doesn't exist";
    fi;
  else
    echo "I need a branch please.";
  fi;
}
