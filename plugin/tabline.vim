" ghostline - a custom statusline/tabline for vim
" (c) QuietMisdreavus 2020

" This Source Code Form is subject to the terms of the Mozilla Public
" License, v. 2.0. If a copy of the MPL was not distributed with this
" file, You can obtain one at http://mozilla.org/MPL/2.0/.

" always show tabline, even when only one tab is active
set showtabline=2

function! MisdreavusIncludeInLeftTabs(b)
    if !bufexists(a:b)
        return v:false
    endif

    if !buflisted(a:b)
        return v:false
    endif

    if a:b == bufnr() || a:b == bufnr('#')
        return v:false
    endif

    if getbufvar(a:b, '&filetype') == 'qf'
        return v:false
    endif

    if bufwinnr(a:b)->getwinvar('&previewwindow', v:false)
        return v:false
    endif

    if UseMisdreavusMRU()
        let idx = index(g:misdreavus_mru[win_getid()], a:b)
        return idx < 0 || idx >= g:misdreavus_mru_rotate_count
    endif

    return v:true
endfunction

function! MisdreavusIncludeInRightTabs(b)
    if !bufexists(a:b)
        return v:false
    endif

    if a:b == bufnr() || a:b == bufnr('#')
        return v:false
    endif

    if UseMisdreavusMRU()
        if index(g:misdreavus_mru[win_getid()], a:b) >= 0
            return v:false
        endif
    endif

    if buflisted(a:b)
        return getbufvar(a:b, '&filetype') == 'qf' || bufwinnr(a:b)->getwinvar('&previewwindow', v:false)
    else
        let visbufs = tabpagebuflist()
        return index(visbufs, a:b) != -1
    endif
endfunction

function! MisdreavusTabSegment(b, fill = '')
    let segment = ''
    let curbuf = bufnr()
    let altbuf = bufnr('#')
    let visbufs = tabpagebuflist()

    if a:b == curbuf
        let segment .= '%#TabLineSel#'
    elseif index(visbufs, a:b) != -1
        let segment .= '%#SignColumn#'
    endif

    " number buffers, but signify the alternate buffer with ^N instead of #N
    let hash = '#'
    if a:b == altbuf
        let hash = '^'
    endif

    if !buflisted(a:b) && getbufvar(a:b, '&filetype') == 'help'
        " help files are not listed, but i want to be able to see my current buffer in the tab
        " bar regardless. i don't want to print the full path tho, so just grab the filename
        let name = bufname(a:b)->fnamemodify(':t')
    elseif getbufvar(a:b, '&filetype') == 'qf'
        let name = misdreavus#qfname(a:b)
    else
        let name = bufname(a:b)
        if name != ''
            let name = fnamemodify(name, ':~:.')->pathshorten()
        endif
    endif

    if name == ''
        let name = '[no name]'
    endif

    let segment .= ' ' . a:fill

    if bufwinnr(a:b)->getwinvar('&previewwindow', v:false)
        let segment .= '[p]'
    else
        let segment .= hash . a:b . ':'
    endif

    let segment .= ' ' . name . ' '

    if getbufvar(a:b, '&mod')
        let segment .= '[+] '
    endif

    if a:b == curbuf || index(visbufs, a:b) != -1
        let segment .= '%#TabLine#'
    endif

    return segment
endfunction

function! MisdreavusDefaultLeadTabs()
    let curbuf = bufnr()
    let altbuf = bufnr('#')

    let s = MisdreavusTabSegment(curbuf)

    if altbuf != -1 && buflisted(altbuf) && altbuf != curbuf
        let s .= '|'
        let s .= MisdreavusTabSegment(altbuf)
    endif

    return s
endfunction

function! UseMisdreavusMRU()
    if !exists('g:misdreavus_mru')
        return v:false
    elseif !has_key(g:misdreavus_mru, win_getid())
        return v:false
    elseif len(g:misdreavus_mru[win_getid()]) < 2
        return v:false
    elseif !exists('g:misdreavus_mru_rotate_count')
        return v:false
    else
        return g:misdreavus_mru_rotate_count > 0
    endif
endfunction

function! MisdreavusMRULeadTabs()
    let bufcount = g:misdreavus_mru_rotate_count
    let printed = 0
    let first = v:true
    let s = ''

    for b in g:misdreavus_mru[win_getid()]
        if first
            let first = v:false
        else
            let s .= '|'
        endif
        let s .= MisdreavusTabSegment(b)

        let printed += 1
        if printed >= bufcount
            break
        endif
    endfor

    return s
endfunction

function! MisdreavusTabline()
    let s = ''
    let suf = ''

    if tabpagenr('$') > 1
        " tabs are being used, display the tab number
        let s .= '%#TODO#'
        let s .= ' tab #' . tabpagenr()
        let s .= ' %999X[X]%X ' " close button
    endif

    let curbuf = bufnr()
    let altbuf = bufnr('#')
    let visbufs = tabpagebuflist()
    let firstbuf = v:true

    let s .= '%#TabLine#'

    if UseMisdreavusMRU()
        let s .= MisdreavusMRULeadTabs()
    else
        let s .= MisdreavusDefaultLeadTabs()
    endif

    for b in range(1, bufnr('$'))
        if MisdreavusIncludeInLeftTabs(b)
            if firstbuf
                let firstbuf = v:false
                let s .= '||'
                let fill = '%<'
            else
                let s .= '|'
                let fill = ''
            endif

            let s .= MisdreavusTabSegment(b, fill)
        endif
    endfor

    if exists('g:ghostline_tab_fill_color')
        let s .= '%#' . g:ghostline_tab_fill_color . '#'
    else
        let s .= '%#TabLineFill#'
    endif

    let firstbuf = v:true

    for b in range(1, bufnr('$'))
        if MisdreavusIncludeInRightTabs(b)
            if firstbuf
                let firstbuf = v:false
                let s .= '%='
            else
                let s .= '|'
            endif

            let s .= MisdreavusTabSegment(b)
        endif
    endfor

    return s
endfunction

set tabline=%!MisdreavusTabline()
