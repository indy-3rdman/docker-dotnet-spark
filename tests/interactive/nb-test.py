import sys
import argparse
import re
import subprocess
import nbformat
from pathlib import Path
from nbconvert.preprocessors import ExecutePreprocessor
from nbconvert.preprocessors import CellExecutionError

parser = argparse.ArgumentParser()
parser.add_argument("path", help="the path to the notebook (.ipynb) file")
args = parser.parse_args()

notebook_filename_path = Path(args.path)
if not notebook_filename_path.is_file():
    sys.stderr.write('file does not exist\n')
    sys.exit(999)

notebook_filename = args.path
notebook_filename_out = re.sub('\.ipynb$', '-out.ipynb',notebook_filename)
print(f"in: {notebook_filename}, out: {notebook_filename_out}")

p = subprocess.Popen(["cd dotnet.spark/examples; pwd; start-spark-debug.sh"],stdin=subprocess.PIPE, shell=True)

with open(notebook_filename) as f:
    nb = nbformat.read(f, as_version=4)

ep = ExecutePreprocessor(timeout=300, kernel_name='.net-csharp')

try:
    out = ep.preprocess(nb, {'metadata': {'path': 'dotnet.spark/examples'}})
except CellExecutionError:
    out = None
    msg = 'Error executing the notebook "%s".\n\n' % notebook_filename
    msg += 'See notebook "%s" for the traceback.' % notebook_filename_out
    print(msg)
    raise
finally:
    with open(notebook_filename_out, mode='w', encoding='utf-8') as f:
        nbformat.write(nb, f)
    p.communicate(input=b'\n')