import argparse
import subprocess

parser = argparse.ArgumentParser(description='Build solidity contract')
parser.add_argument('--input_dir', help='Directory with solidity contract')
parser.add_argument('--input_file', help='File with solidity contract')

args = parser.parse_args()
subprocess.call(['make', 'build', f'input_dir={args.input_dir}', f'input_file={args.input_file}'])
