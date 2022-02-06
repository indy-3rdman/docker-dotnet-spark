#!/usr/bin/env python

__doc__ = """
This script executes .NET for Apache Spark in the background and
runs all cells of a specified notebook.
"""

import sys
import argparse
import re
import subprocess
import nbformat
from pathlib import Path
from nbconvert.preprocessors import ExecutePreprocessor
from nbconvert.preprocessors import CellExecutionError

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("path", help="the path to the notebook (.ipynb) file")
args = parser.parse_args()

# Validate notebook path
notebook_filename_path = Path(args.path)
if not notebook_filename_path.is_file():
    sys.stderr.write('file does not exist\n')
    sys.exit(999)

# Set input and output filenames
notebook_filename = args.path
notebook_filename_out = re.sub(r'\.ipynb$', '-out.ipynb',notebook_filename)
print(f"in: {notebook_filename}, out: {notebook_filename_out}")

# Start .NET for Apache Spark in the background
p = subprocess.Popen(["cd dotnet.spark/examples; pwd; start-spark-debug.sh"],stdin=subprocess.PIPE, shell=True)

# Read the notebook
with open(notebook_filename) as f:
    nb = nbformat.read(f, as_version=4)

# Create a new nbconvert preprocessor using a C# kernel
ep = ExecutePreprocessor(timeout=300, kernel_name='.net-csharp')

try:
    # Process the notebook executing every cell
    out = ep.preprocess(nb, {'metadata': {'path': 'dotnet.spark/examples'}})

except CellExecutionError:
    # Print error message on exception
    out = None
    msg = 'Error executing the notebook "%s".\n\n' % notebook_filename
    msg += 'See notebook "%s" for the traceback.' % notebook_filename_out
    print(msg)
    raise

finally:
    # Write the processed notebook to a new file
    with open(notebook_filename_out, mode='w', encoding='utf-8') as f:
        nbformat.write(nb, f)

    # And end the .NET for Apache Spark background process.
    p.communicate(input=b'\n')