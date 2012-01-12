" vimのカーソル行の内容をOmniFocusのInboxへ送るスクリプト
" https://github.com/fifnel/ofaddinbox.vim

" 動作確認環境
"  Mac OSX 10.7.2
"  OmniFocus 1.9.4

nnoremap ,o :call SingleTaskToOmniFocusInbox()<CR>
vnoremap ,o :call MultiTaskToOmniFocusInbox()<CR>
vnoremap ,n :call SingleNoteTaskToOmniFocusInbox()<CR>

" OmniFocusにタスクを登録する
function! OmniFocusNewInbox(task, note)
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
function! SingleTaskToOmniFocusInbox()
	call OmniFocusNewInbox(getline(getpos(".")[1]), "")

	echo "SingleTask Addded"
endfunction

" 複数タスク登録
function! MultiTaskToOmniFocusInbox() range
	let cur = a:firstline
	let last = a:lastline
	
	while cur <= last
		call OmniFocusNewInbox(getline(cur), "")
		let cur = cur + 1
	endwhile

	echo "MultiTask Addded"
endfunction

" ノート付き単一タスク登録
function! SingleNoteTaskToOmniFocusInbox() range
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
	call OmniFocusNewInbox(task, note)

	echo "SingleNoteTask Addded"
endfunction

