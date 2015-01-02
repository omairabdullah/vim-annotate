# vim-annotate #

A vim plugin for annotation using folds

## Usage ##

Annotate a range of text by using the ':Annotate' command.

e.g.:
        :2,3Annotate "My annotation line"
        :'<,'>Annotate "Annotation of visually selected text"

This creates a fold for the selected range and replaces the foldtext with the
text input by the user.
