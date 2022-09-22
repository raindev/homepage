+++
title = "Granular Git Configuration"
date = 2018-04-16
aliases = [ "granular-git-configuration.html" ]
+++

Even though in most cases having a single Git configuration is enough, sometimes more granular control is needed. Let's say you have a common Git configuration you use on your personal server, a laptop and a desktop. You probably want to share that configuration across the machines as part of your [dotfiles repository](https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/). Also you have a work laptop and you need some special Git configuration for work projects. Occasionally you commit to your personal repositories or some open source repositories from the work laptop and you don't want to have the work configuration applied in those cases. Let's see how you can organize the Git configuration to match the described setup step by step.

## Global configuration

Firstly, the configuration you share between all the machines will be Global Git configuration. It's stored in `~/.gitconfig` (can be modified using `git config --global` commands as well). This file will be the same everywhere and can be in your dotfiles repository. For simplicity let's say the configuration contains user name and email. In my case that would be:

```
[user]
        name = Andrew Barchuk
        email = andrew@raindev.io
```

## Local configuration

To have configuration specific to a particular machine you can include an addition local configuration file by adding the following to `.gitconfig`:

```
[include]
    path = ~/.gittconfig.local
```

Now machine specific Git configuration can be added to `.gitconfig.local`. E.g. to use a different email on your work laptop:

```
[user]
    email = andrew@example.com
```

Any other configuration that should be different for a specific machine can be overwritten the same way.

## Conditional include

The problem arises however if you still want to be able to commit to repositories not related to work using your ordinary email. Instead of overwriting the email on the work laptop globally it can be done only for repositories located in a specific directory where work projects are kept, say `~/work`. `includeIf` can do exactly what we need (see `man 1 git-config` for more details). Here's how .gitconfig.local will look like:

```
[includeIf "gitdir:~/work/"]
    path = ~/.gitconfig.work
```

The email and other work-specific configuration will be placed in `~/.gitconfig.work`. Note that having a trailing `/` after the directory name is important. Now Git won't apply the work-related configuration to your personal dotfiles repository in `~/dotfiles/` but will do that for `~/work/webapp/`.

## Bonus: repository specific configuration

If for some reason you need to change Git configuration only for a single repository for some reason it can be done by editing `.git/config` file or simply with `git config` (no `--global` flag this time).

If you're curious about my dotfiles feel free to check out [the GitHub repository](https://github.com/raindev/dotfiles).
