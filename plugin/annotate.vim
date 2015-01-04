" Location:     plugin/annotate.vim
" Author:       Omair Mohammed Abdullah <http://omair.in>
" Version:      0.1
" License:      Same as Vim itself.  See :help license

if exists("g:loaded_annotate") || v:version < 700 || &cp
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

let s:annotation = ""
let s:separator = "```"
let s:Custom_foldtext = function(g:annotate_custom_foldtext)

let s:annotate_debug = 0
function! s:log(msg)
  if s:annotate_debug == 1
    echom a:msg
  endif
endfunction

set foldenable
set foldtext=annotate#Foldtext()

command! -range -nargs=1 Annotate <line1>,<line2>call annotate#Annotate(<args>)
function! annotate#Annotate(annotate) range
  let fdm_saved = &foldmethod
  let cmd = printf("%d,%dfold", a:firstline, a:lastline)
  let s:annotation = printf("%d%s%d%s%s", a:firstline, s:separator, a:lastline, s:separator, a:annotate)
  call s:log("annotate#Annotate:[" . a:firstline . "," . a:lastline . "]: " . a:annotate)
  set foldmethod=manual
  silent execute cmd
  "let &foldmethod = fdm_saved
endfunction

function! s:get_matching_annotation(annotation_entry)
  let annotation_elems = split(a:annotation_entry, s:separator)
  let new_annotation = ""
  if v:foldstart == annotation_elems[0] && v:foldend == annotation_elems[1]
    let new_annotation = annotation_elems[2]
  endif
  return new_annotation
endfunction

" TODO:
"       1. load folds like in a vim session file
"       2. editing annotation? - currently overriding old annotation
"       3. old folds in fold file - clean up
function! annotate#Foldtext()

  let new_annotation = s:get_matching_annotation(s:annotation)
  if !empty(new_annotation)
    " found an annotation so clear the variable
    let s:annotation = ""
  endif
  call s:log("annotate#Foldtext: annotation:[" . v:foldstart . "," . v:foldend . "]: " . new_annotation)

  let foldchar = matchstr(&fillchars, 'fold:\zs.')
  let shellslash_saved = &shellslash
  set shellslash
  let filename = fnameescape(g:annotate_annotations_folder . "/" . fnameescape(join(split(expand("%:p"), "/"), "_")))
  let &shellslash = shellslash_saved
  call s:log("annotate#Foldtext: file: " . filename)

  let annotations = readfile(filename)
  " Annotations file doesn't exist and need not be created
  if len(annotations) == 0 && empty(new_annotation)
    call s:log("annotate#Foldtext: annotation file does not exist")
    return s:Custom_foldtext()
  endif

  let existing_annotation_found = 0
  for a in annotations
      let foldtext = s:get_matching_annotation(a)
      if !empty(foldtext)
        let existing_annotation_found = 1
        call s:log("annotate#Foldtext: annotation found")
        break
      endif
  endfor

  " This fold does not have any existing or new annotation
  if existing_annotation_found == 0 && empty(new_annotation)
    call s:log("annotate#Foldtext: annotation not found")
    return s:Custom_foldtext()
  endif

  " Either we replace an existing annotation or make a new one
  if !empty(new_annotation)
    let newannotation_entry = "" . v:foldstart . s:separator . v:foldend . s:separator . new_annotation
    call s:log("annotate#Foldtext: new annotation")
    " FIXME: replacing existing annotation is only by putting another
    " annotation _before_ this one
    call insert(annotations, newannotation_entry, 0)
    call writefile(annotations, filename)
    let foldtext = new_annotation
  endif

  return "+" . repeat(foldchar, 2) . repeat(" ", indent(v:foldstart) - 3) . foldtext . "    "
endfunction

" vim:set sw=2 sts=2 et:
