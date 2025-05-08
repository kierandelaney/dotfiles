# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `setup.sh` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
USER="$(id -u -n)"

ZSH=~/.oh-my-zsh

BREWPATH="$(brew --prefix)"

echo "Your brewpath is $BREWPATH"

# Change shell!
echo "\n* Checking for ZSH"
if [ $SHELL == '/bin/zsh' ] ; then
  echo "\t- ZSH already in use, skipped..."
else
  chsh -s $(grep /zsh$ /etc/shells | tail -1)
  echo "\t- ZSH enabled..."
fi

# Backup dotfiles
echo "\n* Backup is non-negotiable!"
dir_backup=~/dotfiles_old
echo "\t- Creating $dir_backup for backup of any existing dotfiles in ~..."
mkdir -p $dir_backup
echo "\t- Backing up existing dotfiles to $dir_backup from ~..."
cp ~/.vimrc ~/dotfiles_old/
cp ~/.zshrc ~/dotfiles_old/
echo "\t- Done"

# Checking if Oh-My-ZSH is git flavoured
if [[ -d $ZSH/.git ]]; then
  echo "\n* Oh-My-ZSH is a git repository, skipping..."
else
  echo "\n* Oh-My-ZSH is not a git repository, cleaning up..."
  rm -rf $ZSH
  echo "\t- Oh-My-ZSH removed..."
fi

# Install Oh-My-ZSH
if [[ ! -d $ZSH ]]; then
  echo "\n* I'm going to install Oh-My-ZSH!"
  git clone -q https://github.com/ohmyzsh/ohmyzsh.git $ZSH
  echo "\t- Oh-My-ZSH installed..."
else
  echo "\n* Oh-My-ZSH alresady installed, skipping..."
fi

# Install powerlevel10k
if [[ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]]; then
  echo "\t- I'm going to install powerlevel10k! https://github.com/romkatv/powerlevel10k"
  git clone -q --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
  echo "\t- powerlevel10k installed..."
else
  echo "\t- powerlevel10k already installed, checking for updates..."
  git -C ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k pull -q
  echo "\t- powerlevel10k updated..."
fi

# Copy dotfiles
cp -R user/ ~
echo "\t- dotfiles installed..."
cp -R oh-my-zsh/custom/ ~/.oh-my-zsh/custom/
echo "\t- Oh-My-ZSH custom files installed..."
echo "DEFAULT_USER='${USER}'" >> ~/.oh-my-zsh/custom/extra.zsh
echo "\t- Added you as a default user!"

# Install Vundle
if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
  echo "\n* I'm going to install Vundle!"
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  echo "\t- Vundle installed..."
else
  echo "\n* Vundle already installed, skipping..."
fi

# Install Vundle Plugins
echo "\n* Installing Vundle plugins..."
vim +PluginInstall +qall
echo "\t- Vundle plugins installed..."

echo "\n* Checking for XCode Command Line Tools..."
if ! xcode-select --print-path &> /dev/null; then
  echo "\t- XCode Command Line Tools installer launching, I'll wait until its finished..."
  # Prompt user to install the XCode Command Line Tools
  xcode-select --install &> /dev/null
  # Wait until the XCode Command Line Tools are installed
  until xcode-select --print-path &> /dev/null; do
    sleep 5
  done
  echo "\t- Installed XCode Command Line Tools"
  # Point the `xcode-select` developer directory to
  # the appropriate directory from within `Xcode.app`
  # https://github.com/alrra/dotfiles/issues/13
  sudo xcode-select -switch /Applications/Xcode.app/Contents/Developer
  echo "\t- Made 'xcode-select' developer directory point to Xcode"
  # Prompt user to agree to the terms of the Xcode license
  # https://github.com/alrra/dotfiles/issues/10
  sudo xcodebuild -license
  echo "\t- Agreed with the XCode Command Line Tools licence"
else
  echo "\t- XCode Command Line Tools installed, skipping..."
fi

echo "\n* Checking for Homebrew installation..."
# Install Homebrew if not installed
if ! hash brew 2>/dev/null; then
  echo "\t- Homebrew missing, installing now"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "\t- Homebrew installed already"
  brew remove chefdk 2>/dev/null   # remove old dk (now chef-workstation) -- do before brew update -- TODO remove once it is gone everywhere
  brew untap chef/chef 2>/dev/null # remove old tap (now a normal cask)   -- do before brew update -- TODO remove once it is gone everywhere
  brew update
  echo "\t- Homebrew updated"
fi

echo "\n* Setting up software requirements"
brew bundle install

# echo "\n* Making sure you have a debug log"
# touch "$BREWPATH"/var/log/httpd/debug_log
# chmod 666 "$BREWPATH"/var/log/httpd/debug_log

# Remove Bad Lint Tools
echo "\n* Checking for tools in misconfigured locations"
if [ -e /usr/local/phpmd ]; then
  echo "\t- /usr/local/phpmd should not exist, will move to /usr/local/bin"
  sudo rm -f /usr/local/phpmd
fi
if [ -e /usr/local/phpcs ]; then
  echo "\t- /usr/local/phpcs should not exist, will move to /usr/local/bin"
  sudo rm -f /usr/local/phpcs
fi
if [ -e /usr/local/phpcbf ]; then
  echo "\t- /usr/local/phpcbf should not exist, will move to /usr/local/bin"
  sudo rm -f /usr/local/phpcbf
fi
if [ -e /usr/local/phpcpd ]; then
  echo "\t- /usr/local/phpcpd should not exist, will move to /usr/local/bin"
  sudo rm -f /usr/local/phpcpd
fi

# Ensure Lint Tools are installed and up to date
echo "\n* Checking tools are installed & up to date"
if [ ! -e /usr/local/bin/phpmd ] || [ "$(/usr/local/bin/phpmd --version)" != "$(tools/phpmd --version)" ]; then
  sudo cp tools/phpmd /usr/local/bin/phpmd
  echo "\t- Installed $(tools/phpmd --version)"
else
  echo "\t- PHPMD installed & up to date"
fi
if [ ! -e /usr/local/bin/phpcs ] || [ "$(/usr/local/bin/phpcs --version)" != "$(tools/phpcs --version)" ]; then
  sudo cp tools/phpcs /usr/local/bin/phpcs
  echo "\t- Installed $(tools/phpcs --version)"
else
  echo "\t- PHPCS installed & up to date"
fi
if [ ! -e /usr/local/bin/phpcbf ] || [ "$(/usr/local/bin/phpcbf --version)" != "$(tools/phpcbf --version)" ]; then
  sudo cp tools/phpcbf /usr/local/bin/phpcbf
  echo "\t- Installed $(tools/phpcbf --version)"
else
  echo "\t- PHPCBF installed & up to date"
fi
if [ ! -e /usr/local/bin/phpcpd ] || [ "$(/usr/local/bin/phpcpd --version)" != "$(tools/phpcpd --version)" ]; then
  sudo cp tools/phpcpd /usr/local/bin/phpcpd
  echo "\t- Installed $(tools/phpcpd --version)"
else
  echo "\t- PHPCPD installed & up to date"
fi

# Ensure global stylelint and jshint
echo "\n* Checking npm tools are installed & up to date"
npm install -g jshint
npm install -g stylelint
npm install -g gulp-cli

# Install the Solarized Dark theme for iTerm
echo "\n"
read -p "* Should I install the iTerm Theme? [yn]" answer
if [[ $answer = [Yy]* ]] ; then
  open "macos/Solarized Dark.itermcolors"
  echo "\t- iTerm Theme installed..."
  echo "\t${RED}- Don't forget to enable the theme and font in iTerm preferences...${NC}"
else
  echo "\t- iTerm Theme skipped..."
fi

echo "\n${GREEN}***\nFINISHED - don't forget to set your font and colourscheme in iTerm2 if you need to!\n***\n${NC}"
