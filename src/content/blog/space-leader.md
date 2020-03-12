+++
title = "Space Leader"
date = 2016-02-27
aliases = [ "space-leader.html" ]
+++

<small>_(written on December 12, 2015)_</small>

# Why I use space as my Vim leader key

One of the best Vim productivity boosts is to configure your leader key. What leader key does - it gives you a namespace for custom mappings. No default Vim mappings use leader key, so you're free to choose whatever shortcuts you like without worrying about conflicts with some predefined mappings. Considering this it makes sense to define custom mappings using leader key. It also facilitates remembering of shortcuts by providing mental separation for the ones you've crafted yourself. To activate a shortcut you just press leader key and than a specific mapping, e.g. I use `<leader>w` to save current file. Configuring such a mapping is quite easy: add `map <leader>w` to your .vimrc and you're done. Noticing things you do repeatedly working day-to-day in Vim and creating custom mappings for them will allow you to save a little bit of time constantly and will make editing with Vim more effortless.

Lots of Vim tutorials recommend to use `,` as leader key. However I see a few benefits of using spacebar instead.

## It doesn't override any default Vim mappings

Contrary to `,`, which is used to move cursor to previous occurrence of a character navigated to using `t` or `f`, space doesn't do any particularly useful in normal mode by default. Yes, it does move cursor to the next character, but the motion is already covered by `l` key anyway (or an arrow key if you like to use those). So we could safely override default space behaviour. `,` is quite important for my workflow on the opposite side.

## Space is easy to reach to

Most of your custom mappings will use leader key, so it should be better easy to type. Spacebar is a huge key placed very conveniently on most keyboards. It's a safe bet regarding ergonomics.

## Space is symmetrical

This one alone is a good reason for me to use spacebar as my leader key. Given it's *equally* easily reachable for *both hands*, space leaves me with all the alphanumeric keys as convenient shortcut options. Again in contrast to `,` which is typed by the right hand making left hand letters more comfortable options for typing shortcuts without stretching fingers.

There's even a text editor (a flavour of Emacs) based around the idea of space key as a gateway to all the editor commands called [Spacemacs](http://spacemacs.org). I've been playing around with it a little bit recently and it has been positive experience so far. Spacemacs goes one step further by providing instant visual feedback about available commands once you've pressed space key.

## Think for yourself

This way to use leader key fits _my_ workflow very well. It may or may not be as efficient in your case. Be critical of that "mappings every Vimmer should use" tips (and of this article as well). Try what works best for *you*, your fingers and your keyboard. If you're interested more in how I use Vim check out my [dotfiles](https://github.com/raindev/dotfiles) GitHub repo. Happy editing!

It would be interesting to know how do you use leader key, join the [Reddit discussion](https://www.reddit.com/r/vim/comments/484isa/why_i_use_space_as_my_vim_leader_key/).
