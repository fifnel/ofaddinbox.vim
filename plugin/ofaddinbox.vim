" Vim global plugin for add task to OmniFocus Inbox
" Last Change:	2012 Jan 12
" Maintainer:	fifnel <fifnel@gmail.com>
" License:		CC BY 3.0
"
" https://github.com/fifnel/ofaddinbox.vim
"
" 動作確認環境
"  Mac OSX 10.7.2
"  OmniFocus 1.9.4


if exists("g:loaded_ofaddinbox")
  finish
endif
let g:loaded_ofaddinbox = 1

let s:save_cpo = &cpo
set cpo&vim


" mappings
nnoremap <silent> <Plug>SingleTaskToOmniFocus :<C-u>SingleTaskToOmniFocus<CR>
vnoremap <silent> <Plug>MultiTaskToOmniFocus :MultiTaskToOmniFocus<CR>
vnoremap <silent> <Plug>SingleNoteTaskToOmniFocus :SingleNoteTaskToOmniFocus<CR>

if !hasmapto('<Plug>SingleTaskToOmniFocus')
	nmap <silent> <Leader>o <Plug>SingleTaskToOmniFocus
endif
if !hasmapto('<Plug>MultiTaskToOmniFocus')
	vmap <silent> <Leader>o <Plug>MultiTaskToOmniFocus
endif
if !hasmapto('<Plug>SingleNoteTaskToOmniFocus')
	vmap <silent> <Leader>n <Plug>SingleNoteTaskToOmniFocus
endif

" commands
command! -nargs=0 SingleTaskToOmniFocus call s:SingleTaskAdd()
command! -range   MultiTaskToOmniFocus <line1>,<line2>call s:MultiTaskAdd()
command! -range   SingleNoteTaskToOmniFocus <line1>,<line2>call s:SingleNoteTaskAdd()


" OmniFocusにタスクを登録する
function! s:OmniFocusNewInbox(task, note)
	let task = '"' . substitute(a:task, "\"", "\\\\\"", "g") . '"'
	let note = '"' . substitute(a:note, "\"", "\\\\\"", "g") . '"'
	let script = "!osascript "
	let script = script." -e 'tell application \"OmniFocus\"'"
	let script = script." -e '	set theDoc to first document'"
	let script = script." -e '	set theTask to " . task . "'"
	let script = script." -e '	set theNote to " . note . "'"
	let script = script." -e '	tell theDoc'"
	let script = script." -e '		make new inbox task with properties {name:theTask, note:theNote}'"
	let script = script." -e '	end tell'"
	let script = script." -e 'end tell'"
	silent execute script
endfunction

" 単一タスク登録
function! s:SingleTaskAdd()
	call s:OmniFocusNewInbox(getline(getpos(".")[1]), "")

	echo "SingleTask Addded"
endfunction

" 複数タスク登録
function! s:MultiTaskAdd() range
	let cur = a:firstline
	let last = a:lastline
	
	while cur <= last
		call s:OmniFocusNewInbox(getline(cur), "")
		let cur = cur + 1
	endwhile

	echo "MultiTask Addded"
endfunction

" ノート付き単一タスク登録
function! s:SingleNoteTaskAdd() range
	let cur  = a:firstline
	let last = a:lastline
	let task = getline(cur)
	let note = ""

	while cur < last
		let cur = cur + 1
		let note = note . getline(cur)
		if cur < last
			let note = note . "\\\n"
		endif
	endwhile
	call s:OmniFocusNewInbox(task, note)

	echo "SingleNoteTask Addded"
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo

