# .dotfiles

These are the files that make me better at using the computer.

## Applications and tools

### neovim

Hey... \*lowers sunglasses\* I use neovim, you know. It's a pretty basic LazyVim setup with a couple tweaks. The theme is called Bamboo.

### tmux

I've actually been using tmux for a while so this one is pretty comprehensive. Having experimented with Zellij (which is also very cool!) I still find that I prefer tmux.

### .zshrc

I found that Oh My Zsh became pretty slow, which I'm sure is a skill issue. The way I solved it was to use zinit and handle a lot more configuration myself, so there's quite a bit going on here. I added some profiling behavior so I can keep a better eye on this.

## Assets

### static/fonts

These are my fonts, and yes, they're encrypted. Pay your designers!!!

## Custom 

### bin/

These are custom tools that are meant to be invoked directly from the command line. They do things that might be useful!

Todo: document these

### scripts/

These are other custom things I've written that support the tools in `bin` or are otherwise used in automation. For the most part, these will need to be sourced manually.

## Todo

Right now, my config files should be manually copied if you want to use them. I'm working on several scripts that will make these easier to try out by managing backups of existing configs and creating symlink. Yes I know about gnu-stow, I'm just a sick individual who enjoys writing bash scripts.

I'm also working on getting all my other configurations added to this repo. It's way past time I start tracking my dotfiles in version control, but it's a work in progress :)
