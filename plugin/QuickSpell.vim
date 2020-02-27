setlocal spell
set cmdheight=2

let g:quickspellpending = 0
let g:quickspellchar = ' '
au InsertLeave * let g:quickspellpending = 0
hi QuickSpellNum cterm=bold ctermfg=gray 
hi QuickSpellSug cterm=bold ctermfg=green
hi QuickSpellSel cterm=bold ctermfg=magenta
fun! Col2Key(col)
    for l:i in range(0,20)
	if l:i*&columns>a:col*10
	    return l:i
	endif
    endfor
endfun

fun! QuickSpellDraw(sel)
    let l:col = 0
    let l:num = -1
    for l:i in range(0, len(g:quickspellsugs)-1)
	while Col2Key(l:col) <= l:num
	    let l:col += 1
	    echon ' '
	endwhile
	let l:num = Col2Key(l:col)
	if l:num >= 10
	    break
	endif
	let g:quickspellnums[l:i] = l:num
	echohl QuickSpellNum
	echon l:num
	if a:sel == l:i
	    echohl QuickSpellSel
	else
	    echohl QuickSpellSug
	endif
	echon g:quickspellsugs[l:i]
	echohl None
	let l:col += 1 + len(g:quickspellsugs[l:i])
	"if len(g:quickspellsugs[l:i])<=4
	    "let l:num = Col2Key(l:col-1)
	"endif
    endfor
endfun

fun! QuickSpellShow(key)
    let l:word = matchstr(getline('.')[:col('.')-2],'\zs\a*\ze$')
    if getline('.')[col('.')-len(l:word)-2] == '\'
	echo ''
	return a:key
    endif
    let g:quickspellsugs = spellsuggest(l:word, 9)
    if len(g:quickspellsugs) == 0
	echo ''
	let g:quickspellpending = 0
        return a:key
    endif
    let g:quickspellnums=[&columns,&columns,&columns,&columns,&columns,&columns,&columns,&columns,&columns,&columns,&columns]
    call QuickSpellDraw(-1)
    let g:quickspellpending = 1
    let g:quickspellchar = a:key
    return a:key
endfun

func! QuickSpellSelect(n)
    if g:quickspellpending
        for l:i in range(0,9)
            if a:n>=g:quickspellnums[l:i] && a:n<g:quickspellnums[l:i+1]
                let l:j=l:i
                break
            endif
        endfor

        call QuickSpellDraw(l:j)

	if getline('.')[col('.')-2] == g:quickspellchar
            return "\<c-c>bcw".g:quickspellsugs[l:j]."\<Right>"
	else
            return "\<c-c>F\<Space>bcw".g:quickspellsugs[l:j]."\<c-c>ea"
	endif
    else
        return string(a:n)
    endif
endfun

func! QuickSpellRetype()
    echo ''
    if g:quickspellpending
        if getline('.')[col('.')-2] == g:quickspellchar
            return "\<Esc>bcw\<Del>"
        else
    	return "\<Esc>dawbcw"
        endif
    endif
endfun

func! QuickSpellCancel(c)
    echo ''
    let g:quickspellpending = 0
    return a:c
endfun

inoremap <expr> <Space> QuickSpellShow("\<Space>")
inoremap <expr> - QuickSpellShow("-")
inoremap <expr> , QuickSpellShow(",")
inoremap <expr> . QuickSpellShow(".")
inoremap <expr> : QuickSpellShow(":")
inoremap <expr> ; QuickSpellShow(";")
inoremap <expr> ? QuickSpellShow("?")
inoremap <expr> ! QuickSpellShow("!")
inoremap <expr> ' QuickSpellShow("'")
inoremap <expr> 1 QuickSpellSelect(1)
inoremap <expr> 2 QuickSpellSelect(2)
inoremap <expr> 3 QuickSpellSelect(3)
inoremap <expr> 4 QuickSpellSelect(4)
inoremap <expr> 5 QuickSpellSelect(5)
inoremap <expr> 6 QuickSpellSelect(6)
inoremap <expr> 7 QuickSpellSelect(7)
inoremap <expr> 8 QuickSpellSelect(8)
inoremap <expr> 9 QuickSpellSelect(9)
inoremap <expr> 0 QuickSpellRetype()
inoremap <expr> $ QuickSpellCancel('$')
inoremap <expr> \ QuickSpellCancel('\')

