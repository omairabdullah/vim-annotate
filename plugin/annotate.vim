" Location:     plugin/annotate.vim
" Author:       Omair Mohammed Abdullah <http://omair.in>
" Version:      0.1
" License:      Same as Vim itself.  See :help license

if exists("g:loaded_annotate") || &cp
  finish
endif
let g:loaded_annotate = 1

if !exists("g:annotate_custom_foldtext")
  let g:annotate_custom_foldtext = "foldtext"
endif

if !exists("g:annotate_annotations_folder")
  echom "vim-annotate Error: please set the g:annotate_annotations_folder variable to an existing annotation folder location"
  finish
endif

let s:annotate_debug = 1
function! s:log(msg)
  if s:annotate_debug == 1
    echom a:msg
  endif
endfunction

set foldtext=annotate#Foldtext()

command! -range -nargs=1 Annotate <line1>,<line2>call annotate#Annotate(<args>)
function! annotate#Annotate(annotate) range
  let fdm_saved = &foldmethod
  let cmd = printf("%d,%dfold", a:firstline, a:lastline)
  " Hacky - use script global variable to pass annotation to foldtext function
  let s:annotation = a:annotate
  call s:log("Annotate() - " . s:annotation)
  set foldmethod=manual
  silent execute cmd
  "let &foldmethod = fdm_saved
endfunction

" TODO:
"       1. load folds like in a vim session file
"       2. editing annotation? - currently overriding old annotation
"       3. old folds in fold file - clean up
function! annotate#Foldtext()
  if v:version < 700
    return foldtext()
  endif

  call s:log("Annotation: " . s:annotation)
  let annotation = s:annotation
  let s:annotation = ""
  let separator = "```"
  let foldchar = matchstr(&fillchars, 'fold:\zs.')
  let shellslash_saved = &shellslash
  set shellslash
  let filename =  fnameescape(g:annotate_annotations_folder . "/" . fnameescape(join(split(expand("%:p"), "/"), "_")))
  let &shellslash = shellslash_saved
  call s:log("Annotate file: " . filename)

  let annotations = readfile(filename)
  " Annotations file doesn't exist and it is a normal fold
  if len(annotations) == 0 && annotation == ""
    let Custom_foldtext = function(g:annotate_custom_foldtext)
    return Custom_foldtext()
  endif

  let found = 0
  for a in annotations
      let annot = split(a, separator)
      if v:foldstart == annot[0] && v:foldend ==? annot[1]
        let foldtext = annot[2]
        let found = 1
        break
      endif
  endfor

  if found == 0
    if annotation ==? ""
      let Custom_foldtext = function(g:annotate_custom_foldtext)
      return Custom_foldtext()
    endif
    let newannotation = "" . v:foldstart . l:separator . v:foldend . l:separator . annotation
    call insert(annotations, newannotation, 0)
    call writefile(annotations, filename)
    let foldtext = annotation
  endif
  return "+" . repeat(foldchar, 2) . repeat(" ", indent(v:foldstart) - 3) . foldtext . "    "
endfunction

" vim:set sw=2 sts=2 et:
