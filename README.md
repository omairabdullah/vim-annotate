# vim-annotate #

A vim plugin for annotation using folds

## Usage ##

Annotate a range of text by using the `:Annotate` command.

e.g.:

        :2,3Annotate "My annotation line"
        :'<,'>Annotate "Annotation of visually selected text"

This creates a fold for the selected range and replaces the foldtext with the
text input by the user. This is really useful when reading code, as you can
fold blocks of code with your own annotations. These annotations are saved and
can be later restored (refer docs).

## Screenshots ##

![vim-annotate_before](https://raw.githubusercontent.com/omairabdullah/vim-annotate/images/images/vim_annotate_before_folding.png)
To annotate, select a range of text and call `:Annotate`.

![vim-annotate_after](https://raw.githubusercontent.com/omairabdullah/vim-annotate/images/images/vim_annotate_after_folding.png)
The selected text is folded with the given annotation as the foldtext.

## Installation ##

I recommend using a plugin manager to install this plugin. Vundle, Pathogen and
NeoBundle are all really good plugin managers. Otherwise, unzip the zip file
to your `.vim` directory.

Create a folder to hold the annotations and add a line to your `.vimrc` to
setup the annotations folder.

    let g:annotate_annotations_folder = <path to annotations folder>

Once setup, you can use the exposed `:Annotate` command on any range of
visually selected text to make your annotation.

The annotation will be visible as the foldtext whenever that fold is closed.
