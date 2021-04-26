import re

HEADER = '''
import enum


class Errors(enum.IntEnum):
'''

if __name__ == '__main__':
    with open('../../../contracts/Lib.sol', 'r') as lib:
        content = lib.read()
    library = re.findall(r'Errors {((?:.|\n)*?)}', content)[0]
    errors = list()
    for line in library.splitlines():
        line = line.strip()
        if line.startswith('uint16 constant'):
            name, code = line.replace('uint16 constant', '').split('=')
            name = name.strip(' ;')
            code = code.strip(' ;')
            errors.append((code, name))
            print(name, code)
    with open('errors.py', 'w') as file:
        file.write(HEADER.lstrip())
        for code, name in errors:
            file.write(f'    {name} = {code}\n')
