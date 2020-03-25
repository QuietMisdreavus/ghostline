" custom tabline
" shows buffers, even when tabs are in use
" if a help window is visible, shows it on the right side of the bar

" always show tabline, even when only one tab is active
set showtabline=2

function! MisdreavusIncludeInLeftTabs(b)
    return bufexists(a:b) && buflisted(a:b) && (getbufvar(a:b, '&filetype') != 'qf')
endfunction

function! MisdreavusIncludeInRightTabs(b)
    if !bufexists(a:b)
        return v:false
    endif

    if buflisted(a:b)
        " TODO: add preview window?
        return getbufvar(a:b, '&filetype') == 'qf'
    else
        let visbufs = tabpagebuflist()
        return index(visbufs, a:b) != -1
    endif
endfunction

function! MisdreavusTabSegment(b)
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
        if has_key(s:loclists, a:b)
            " the location list also uses the 'qf' filetype, so check whether this window is a
            " location list first
            let name = s:loclists[a:b]
        else
            " the quickfix list's name isn't in the bufname, but behind this `getqflist` api
            let name = getqflist({'qfbufnr': a:b, 'title': 0}).title
        endif
    else
        let name = bufname(a:b)->pathshorten()
    endif

    if name == ''
        let name = '[no name]'
    endif

    let segment .= ' ' . hash . a:b . ':'
    let segment .= ' ' . name . ' '

    if getbufvar(a:b, '&mod')
        let segment .= '[+] '
    endif

    if a:b == curbuf || index(visbufs, a:b) != -1
        let segment .= '%#TabLine#'
    endif

    return segment
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

    for b in range(1, bufnr('$'))
        if MisdreavusIncludeInLeftTabs(b)
            if firstbuf
                let firstbuf = v:false
            else
                let s .= '|'
            endif

            let s .= MisdreavusTabSegment(b)
        endif
    endfor

    " color remainder light
    let s .= '%#Folded#'

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

" keep a cache of the active location list buffers and their titles
let s:loclists = {}

function! s:refresh_loclists()
    let loclists = {}
    for win in range(1, winnr('$'))
        let loc = getloclist(win, {'qfbufnr':0, 'title':0})
        if loc.qfbufnr != 0 && !has_key(loclists, loc.qfbufnr)
            let loclists[loc.qfbufnr] = loc.title
        endif
    endfor

    let s:loclists = loclists
endfunction

" refresh the location list cache when buffers are changed
augroup tabline
    autocmd!
    autocmd BufAdd * call <sid>refresh_loclists()
    autocmd BufDelete * call <sid>refresh_loclists()
augroup END

set tabline=%!MisdreavusTabline()
