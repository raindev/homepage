---
title: Space Leader
date: February 27, 2016
---

###### (Written on December 12, 2015)

# Why I use Space as my leader key

One of the best Vim productivity boosts is configuring your leader key. What <leader> keys actually does is it gives you a namespace for custom mappings. No default Vim mappings use leader key, so you're free to choose whatever shortcuts you like without worrying about conflicts with some predefined mappings. To activate a shortcut you just press leader key and than a specific mapping, e.g. I use <leader>w to save current file. Configuring such a mapping is quite easy: add `map <leader>w` to your .vimrc and you're done. Noticing things you do repeatedly working day-to-day in Vim and creating custom mappings for them will allow you to save a little bit of time constantly and make editing with Vim more effortless. Given this convenience it makes sense to define custom mappings using leader key. It also ease remembering of commands by providing mental separation for the ones you've crafted yourself.

Lots of Vim tutorials recommend to use `,` as leader key. However I see a few benefits of using spacebar instead.

## It doesn't override any default Vim mappings

Contrary to `,`, which is used  to navigate to previous occurrence of a character navigated to using `t` or `f`, space doesn't do any particularly useful in normal
mode by default. Yes it does move cursor to the next character, but it is already covered by `l` key (or arrow key, if you like to use those) anyway, so we could safely ignore those. `,` is quite important for my workflow on the opposite side.

## Space is easy to reach to

Most of your custom mappings will use leader key, so it's better to be easy to type. Spacebar is huge key placed very conveniently on most keyboard and is a safe bet regarding ergonomics.

## Space is symmetrical

This one alone is a good reason for me to use spacebar as my leader key. Given that it's *equally* easily reachable for *both hands* space leaves me with all the alphanumeric keys as convenient shortcut options. Again in contrast to `,` which  is typed by the right hand making left hand letters more ergonomic options for shortcuts to not stretch fingers of my right hand.


## Think for yourself

Be critical of that "mappings every Vimmer should use" tips (and of this article as well). Try what works best for *you*, your fingers and your keyboard. If you're interested more in how I use Vim check out my dotfiles GitHub repo. Happy editing!
