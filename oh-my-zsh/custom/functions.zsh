# Create a new directory and enter it
function mkd() {
  mkdir -p "$@" && cd "$_";
}

# Change working directory to the top-most Finder window location
function cdf() { # short for `cdfinder`
  cd "$(osascript -e 'tell app "Finder" to POSIX path of (insertion location as alias)')";
}

# Determine size of a file or total size of a directory
function fs() {
  if du -b /dev/null > /dev/null 2>&1; then
    local arg=-sbh;
  else
    local arg=-sh;
  fi
  if [[ -n "$@" ]]; then
    du $arg -- "$@";
  else
    du $arg .[^.]* ./*;
  fi;
}

# Use Git’s colored diff when available
hash git &>/dev/null;
if [ $? -eq 0 ]; then
  function diff() {
    git diff --no-index --color-words "$@";
  }
fi;

# Reloads ~/.zshrc.
function reload() {
  local zshrc="$HOME/.zshrc"
  if [[ -n "$1" ]]; then
    zshrc="$1"
  fi
  source "$zshrc"
}

# Takes one variable and connects to the server with tmux eg; "inn 10.7.2.4" > "ssh innkeeper@10.7.2.4"
function inn () {
  if [[ $# -eq 1 ]] ; then
    ssh innkeeper@$1 -t "tmux -u -CC new -A -s $USER"
  else
    echo "I need a server please!";
  fi;
}

# Flattens logs
function flatlogs() {
  sudo truncate -s 0 /usr/local/var/log/httpd/error_log;
  sudo truncate -s 0 /usr/local/var/log/httpd/access_log;
  sudo truncate -s 0 /usr/local/var/log/php-fpm.log;
  sudo truncate -s 0 /var/log/apache2/error_log;
  sudo truncate -s 0 /usr/local/var/log/httpd/debug_log;
  sudo truncate -s 0 /var/log/apache2/access_log;
}

# This will take any local tracking branches that are no longer on the remote and bin them.
function gitprune() {
  git fetch -p && for branch in `git branch -vv | grep ': gone]' | awk '{print $1}'`; do git branch -D $branch; done
}
