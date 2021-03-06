# ghostline

*a vim statusline/tabline created and preferred by a certain ghost-type pokémon*

![markdown sample](images/gl-markdown.png)\
![vim help file sample](images/gl-help.png)\
![rust sample](images/gl-rust.png)\
![rust sample in lucius dark](images/gl-rust-luciusdark.png)\
![rust sample in zenburn](images/gl-rust-zenburn.png)

`ghostline` started as an experiment to write my own status-bar and tab-bar and understand the
things that [vim-airline] was doing under-the-hood to create its fancy UI. Over time it became one
of my testbeds for writing vim-script and displaying more information in a relatively compact form.

[vim-airline]: https://github.com/vim-airline/vim-airline

The statusline includes integration with [vim-fugitive][] (displaying the current branch/commit) and
[ALE][] (displaying the number of errors in the current buffer, if any.

[vim-fugitive]: https://github.com/tpope/vim-fugitive
[ALE]: https://github.com/dense-analysis/ale

If there is an active quickfix or location list, the count and current item number will be
displayed:

![quickfix counter](images/gl-quickfix.png)\
![location list counter](images/gl-ale-count.png)

If there are files in the argument list, the count and current index will also be displayed. Local
argument lists will be displayed in the window for that list; the global argument list will be
displayed in the first window that doesn't have a local list.

## tabline

`ghostline` also includes a custom tabline, displaying active buffers, including their `modified`
status:

![tabline sample](images/gl-tabline.png)

Certain kinds of buffers (help windows, quickfix/location list windows, preview windows) will only
be shown in the tabline if they're currently visible. If one of these windows isn't the
currently-active one, they will be displayed on the right side of the tabline:

![tabline with help window visible on the right](images/gl-tabline-help.png)

If there are active tabs, the buffer list will continue to be displayed, but an additional indicator
will be added with the number of the current tab:

![tabline with a current-tab indicator](images/gl-tabline-withtab.png)

The current buffer will always be shown in the top left. Right next to it is the buffer for the
"alternate" file (`:help alternate-file`), which can be accessed using `Ctrl-^` (`:help CTRL-^`).
The alternate file's buffer is also indicated using a `^` by the buffer number instead of `#`. The
remaining buffers are then listed after that.

If [`misdreavus-mru`] is installed and enabled, the MRU list for the current window is used for the
"lead tabs" instead, meaning that the buffer before the "lead tabs" marker (the `||` in the bar or
the last buffer if no `||` is listed) will be the one switched to with the `<Plug>RotateMru` action.

[`misdreavus-mru`]: https://github.com/QuietMisdreavus/misdreavus-mru

### fill color

The highlight color used to color the blank space between the "left tabs" and "right tabs" is
configurable by setting the `g:ghostline_tab_fill_color` variable. For example, the sample images
here use the `Folded` color. I recommend configuring this per-color scheme, using something like
this:

```vim
function! SetTabFill(colors_name)
    if a:colors_name == 'lucius'
        let g:ghostline_tab_fill_color = 'Folded'
    else
        unlet! g:ghostline_tab_fill_color " defaults to TabLineFill
    endif
endfunction

augroup GhostlineVimrc
    autocmd!
    autocmd ColorSchemePre * call SetTabFill(expand('<amatch>'))
augroup END
```

If you set the autocmd after you call `:colorscheme` in your configuration, you may need to add a
`call SetTabFill(g:colors_name)` to make sure that it's properly set up when Vim is loaded.

## installing

Point your preferred plugin manager at `'QuietMisdreavus/ghostline'`, or clone this repo into your
`pack/` or `bundle/` folder, or however you add vim plugins to your config.

## license

`ghostline` is available under the terms of the Mozilla Public License, version 2.0. For more
information, check the LICENSE file.
