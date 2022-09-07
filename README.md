# Innserve Dotfiles

This is my collection of dotfiles for configuration of various development tools and some personal preferences for macOS. Feel free to use them.

## Config Files
This repository contains config files for apache, freetds, mysql & php - you should read [this wiki page](http://wiki.innserveltd.co.uk/index.php/How_to_set_up_a_Mac_for_developing) if you're not sure how to use them.

## Mac Defaults
These are a series of sensible defaults for macOS. Maybe read through and check there isn't anything you strongly disagree with first. I will enforce sensible scrolling. I reduce animation durations etc.

```sh
$ cd macos
$ ./.macos
```

## Dotfiles Installation

```sh
$ ./setup.sh
```

Usage as follows:
- Standard files are backed up
- The dotfiles and folders inside `user` are copied into your home directory.
- Be careful what you overwrite! If you have custom aliases, functions or prompt settings etc consider merging them first.
- Any extra information can be added to `~/.oh-my-zsh/custom/extra.zsh` depending on your choice of shell (hint: it should be zsh) - useful for passwords etc

# Zsh

ZSH is a better shell than bash. It's installed in OS X by default. Bundled ZSH is usually recent (at point of OS release anyway) so there isn't much
of a drive to install bleeding edge versions from Homebrew.

### Oh My Zsh

Oh My Zsh is basically a packaged set of themes, plugins and defaults for ZSH. More info here: https://github.com/robbyrussell/oh-my-zsh

##### Changing your default shell
You do not need to do this manually.

### Install a patched font

> **Important** If you install the macOS defaults, font installation is taken care of for you. You will still need to set the font in iTerm2.

- [Meslo](https://github.com/Lokaltog/powerline-fonts/blob/master/Meslo/Meslo%20LG%20M%20DZ%20Regular%20for%20Powerline.otf) (the one in the screenshot). Click "view raw" to download the font.
- [Others @ powerline fonts](https://github.com/powerline/fonts)

Fonts are installed automatically

Set this font in iTerm2 (14px is my personal preference) (iTerm -> Preferences -> Profiles -> Text -> Change Font).

Restart iTerm2 for all changes to take effect.

### Shorter prompt style

By default, your prompt will now show “user@hostname” in the prompt. This will make your prompt rather bloated.

We set `DEFAULT_USER` in `~/.oh-my-zsh/custom/extra.zsh` to your regular username to hide the “user@hostname” info when you’re logged in as yourself on your local machine.

### Add custom commands without creating a new fork

Initially $ZSH_CUSTOM points to oh-my-zsh's custom directory `~/.oh-my-zsh/custom`. Whatever you place inside of it will take precedence over the built-in configuration. For example, `~/.oh-my-zsh/custom/extra.zsh` can contain your default username (see above).

My `~/.oh-my-zsh/custom/git.zsh` looks something like this:

```bash
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Kieran Delaney"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="kieran.delaney@innserveltd.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"
```

You can use `~/.oh-my-zsh/custom/` to override any settings, functions and aliases. It’s probably better to [fork this repository](http://git.innserveltd.co.uk/kdelaney/dotfiles/forks/new) instead, though. If you fork and commit your personal changes you'll have them backed up and version controlled.

:)
