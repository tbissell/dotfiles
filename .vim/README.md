# Tim's VIM configuration

This is my personal configuration for VIM using a series of plugins that I
have found useful, but not too intrusive.

## Installation

Installation is very quick, and the setup.sh script listed below only runs
a few commands to get things set up quickly.

    git clone http://github.com/tbissell/dotvim ~/.vim
    cd ~/.vim
    ./setup.sh

## Custom keybinds and functions

While I don't suggest anyone just pull and use my entire configuration, there
may be some interesting parts to pull out and incorporate into your own
configuration. I'll try to list the pertitent custom parts here, by mode.

Also to note, I use expandtabs and annoying visual characters for tabs and
trailing whitespace to keep my files clean.

Normal:

    <Leader>nt      - Open NerdTree
    <Leader>tl      - Open TagBar

    <Leader>gc      - Git commit (fugitive)
    <Leader>gs      - Git status (fugitive)
    <Leader>gd      - Git diff (fugitive)
    <Leader>gp      - Git push (fugitive)
    <Leader>gd      - Git diff (fugitive)
    <Leader>gl      - Git log (fugitive)
    <Leader>gb      - Git blame (fugitive)

    <Leader>om      - markdown preview using grip + xdg-open

    <Leader>t       - open terminal
    <Leader>st      - send line to terminal

    <Leader>f       - toggle fold column/gutter/etc

    <Leader>ll      - open location list (:lopen)
    <Leader>z       - Open fold, close all others
    <Leader><space> - Clear search highlight
    <Leader>/       - recursvie grep into quickfix list
    <C-j>           - move down line in quickfix
    <C-k>           - move up line in quickfix
    <Leader>w       - remove all trailing whitespace in buffer
    <Leader>r       - run the file being edited

Visual:

    <               - outdent selection and reselect
    >               - indent selection and reselect
    ;bc             - send selection to bc, display calculated result
    <C-t>           - send selection to perltidy, replace with result
    ;st             - send selection to terminal
    ;r              - run selection in new terminal

Insert:

    <C-]>           - function omni complete
    <C-f>           - file omni complete
    <C-l>           - snippet expansion (SnipMate)

## Plugins

### Vundle

Vundle is my primary way to update these various plugins. I only use two
commands from this plugin, but it is very helpful for maintenance.

To perform the initial installation of plugins that are specified in vimrc:

    :PluginInstall

To update the plugins specified in vimrc:

    :PluginUpdate

![vundle](https://raw.github.com/tbissell/dotvim/master/images/vundle.png)

### Colorschemes

A set of colorschemes which I haven't been using, but did provide much
needed information on my own theme included in this repository.

### CtrlP

The handy-dandy fuzzy file finder plugin. Another plugin that does not need
many keybinds, but provides a very nice functionality.
At it's core, these
are the only things that I personally use:

    <C-p>       # opens CtrlP pane

From inside the CtrlP pane:

    <C-r>       # switch to regex search
    <F5>        # refresh cached file listing

There are numerous other options, but the above is enough for me

![ctrlp](https://raw.github.com/tbissell/dotvim/master/images/ctrlp.png)

### vim-gutentags

This plugin automates the update of your ctags data. There are no keybinds
needed, simply having ctags installed, and opening files will update your
tags file.

### NerdTree

Gives an effectively tree-style file browser.

![nerdtree](https://raw.github.com/tbissell/dotvim/master/images/nerdtree.png)

### PerlOmni

Enables Omni completion for perl. The following options need to be specified:

    filetype on
    filetype plugin on
    filetype indent on

To trigger omni completion:

    <C-x> <C-o>

### Airline

Airline is a nice update to the status bar. Newer versions depend on
a couple things that are sometimes not available. The first is that it requires
built-in python support for 2.6+. Most installations at least have this
available.

The second part, is that it uses patched fonts. It will function without them,
but does not look as nice. The fonts used can be found here:
[Powerline Fonts](http://github.com/powerline/fonts)

### Surround

Tim Popes somewhat famous surround plugin. I can describe it no better than
the included help documentation.

    :help surround

### Syntastic

Provides automatic syntax/lint and error checking. This is a handy feature but
may take some tweaking depending on the language being used. This is fairly
in-depth, but I can show some a simplistic example.

![syntastic](https://raw.github.com/tbissell/dotvim/master/images/syntastic.png)

### Tabular

A plugin to make code better looking and/or making quick tables in text

before:

    $thing1 = test;
    $i = 0;
    $thingwithareallydamnlongname = "$thing1";

Using the following commands, makes things "prettier":

    vip:Tab /=

after:

    $thing1                       = test;
    $i                            = 0;
    $thingwithareallydamnlongname = "$thing1";

### TagBar

TagBar is another interface to your tags information. In particular,
this will open a pane that displays the tags for the current buffer/project.

### Fugitive

An interface to git which lets you perform operations without leaving vim.
This is a fairly extensive plugin, so I will not be able to encompass it's
functionality within this small document. I suggest the in editor docs:

    :help fugitive

### GitGutter

This plugin provides an indication in the left column of a line-by-line state
of the current file vs git.

![gitgutter](https://raw.github.com/tbissell/dotvim/master/images/gitgutter.png)

### Rails

This plugins is expansive, and I can do no better than pointing to the docs.
Suffice to say that it helps with rails development.

    :help rails

### Emmet

This plugin enables incredibly fast construction of html structures. The idea
is to use CSS selector notation as markup to expand into html. For example:

    div#page>div.logo+ul#navigation>li*5>a

At the end of line in normal or insert mode:

    <C-y> ,

turns into:

    <div id="page">
        <div class="logo"></div>
        <ul id="navigation">
            <li><a href=""></a></li>
            <li><a href=""></a></li>
            <li><a href=""></a></li>
            <li><a href=""></a></li>
            <li><a href=""></a></li>
        </ul>
    </div>

### Snipmate

Snippets for VIM, yay! Not much to explain here, except that I tend to use a
different keybinding, ex:

    ddate<C-l>

    December 01, 2015

To check out and/or modify the snippets, have a peek in this directory:

    ~/.vim/bundle/snipmate.vim/snippets/

### Commentary

Comment/uncomment lines by motion commands, for example:

    gcip

This will comment/uncomment (gc) every line matched by the ip movement (inner
paragraph).

### SpeedDating

This plugin is used for updated date/time stamps to current in UTC or local
very quickly, ex:

    Fri Dec 31 23:59:59 UTC 1999

From anywhere inside the date string:

    d<C-x>

results in:

    Tue Dec 1 13:57:14 EST 2015

### TSlime

Enables the use of `<C-c> <C-c>` on a selection of text to send it to a
given tmux pane.
