#!/usr/bin/env python3
import os
import sys
import yaml
from jinja2 import Environment, FileSystemLoader
from jinja2_markdown import MarkdownExtension
from distutils.dir_util import copy_tree

if len(sys.argv) != 3:
    print("Two arguments expected, found %s.\n\n    usage: fn-generator.py <source> <dest>\n" % (len(sys.argv)-1))
    exit(1)
else:
    inputdir = sys.argv[1]
    outputdir = sys.argv[2]

# Attempt to create output directory
try:
    os.mkdir(outputdir)
except FileExistsError:
    pass

# Copy _assets into _output
copy_tree(os.path.join(inputdir, '_assets'), outputdir)

# Populate yaml data
print("Indexing data files...")
data = {}
for file in os.listdir(os.path.join(inputdir, '_data/')):
    if file.endswith('.yaml'):
        dataset = file[:-5]
        print("    {}".format(dataset))
        with open(os.path.join(os.path.join(inputdir, '_data/'), file)) as stream:
            data[dataset] = yaml.safe_load(stream)

# Find all template pages
print("Indexing template pages...")
pages = []
for file in os.listdir(os.path.join(inputdir, '_source/')):
    if file.endswith('.html'):
        page = file[:-5]
        print("    {}".format(page))
        pages.append(page)
data['pages'] = pages

# Create jinja2 environment
environment = Environment(
        loader = FileSystemLoader([os.path.join(inputdir, '_source'), os.path.join(inputdir, '_includes')])
    )
environment.add_extension(MarkdownExtension)

# Process template pages
print("Generating pages...")
for file in os.listdir(os.path.join(inputdir, '_source/')):
    if file.endswith('.html') or file.endswith('.rss'):
        if file.endswith('.html'):
            page = file[:-5]
            data['page'] = page
        else:
            page = file[:-4]
            if 'page' in data:
                del data['page']
        
        print('    {}: {} => {}'.format(page, os.path.join(os.path.join(inputdir, '_source/'), file), os.path.join(outputdir, file)))
        
        template = environment.get_template(file)
        file = open(os.path.join(outputdir, file), 'w')
        file.write(template.render(data=data))
        file.close()
print("Done!")
