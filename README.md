# foss-north static site generator - mkII

_Copyright(C) 2020 foss-north ek.för_

This is the foss-north static site generator. Since I'm tired of Ruby, I decided to drop Jekyll and look into Jinja myself. This small setup allows me to create a data driven site from YAML files and Jinja templates.

The idea is to build the static site from a set of independent data driven sites, and at the same time encapsulate my way of working and eliminate most manual steps.

# Setup and top-level usage

In `source` all FOSS-North events have been included as directories with git submodules (or simply with their contents). Make sure to update `image-conversions.conf` when adding contents here.

Create a python3 venv using `requirements.txt`.

Clone the static web repo as `build`.

Run `update-site.sh`.

The results end up in `build`. Do git stuff to push to the server.

# Detailed info

## Image conversions

Each event may contain a tree of original images, commonly named `originals`. The `convert-images.sh` script performs conversions based on the `image-conversions.conf` file. Each line in the `conf` file is interpreted as:

_scope_ `:` _source_ `:` _destination_ `:` _size_

The images are converted from `source/` + _scope_ + `/` + _source_ to `source/` + _scope_ + `/` + destination. All files are converted to `png`, resized and centered on a white background.

The `remove-converted-images.sh` uses the same search algorithm as `convert-images.sh` but removes the destination files. Useful if you want to avoid duplicating images.

## Static site generator

The `fn-generator.py` script takes two directories as arguments: source base path and destination base path. The source directory is expected to contain the following:

* `_source/` - source `*.html` files. These are Jinja templates and each file results in the corresponding file being rendered to the `_output/` directory.
* `_includes/` - includeable files. These are Jinja templates included or extended from the files in the `_source/` directory.
* `_data/` - data set `*.yaml` files. These files are exposed as variables under the global `data` variable when rendering pages.
* `_assets/` - raw assets. This subtree is copied into the `_output/` directory.

The result from processing these files are copied into the output directory.

When rendering the pages from the `_source/` directory the global variable `data` is exposed to Jinja. This variable contains the following sub-variables:

* `data.page` the name of the current page without file extension, e.g. when rendering `index.html` the variable `data.page` is set to `index`.
* `data.pages` a list of all page names without file extensions.
* `data.N`, where _N_ corresponds to a YAML file from the `_data/` directory. Each _N_ the contains the contents of the associated YAML file.
