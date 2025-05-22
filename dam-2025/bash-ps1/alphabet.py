from z3 import *

between = lambda a, p, q: And(a >= p, a <= q)
is_digit = lambda a: between(a, ord('0'), ord('9'))
is_alpha = lambda a: Or(
    between(a, ord('a'), ord('z')),
    between(a, ord('A'), ord('Z')),
)

file = [Int(f'f_{i}') for i in range(57)]

ascii_printables = [
    between(f, ord(' '), ord('~'))
    for f in file
]


unique = Distinct(*file)

order = [
    Or(
        And(is_digit(file[i]) == is_digit(file[i + 1]), file[i] < file[i + 1]),
        And(is_digit(file[i]), Not(is_digit(file[i + 1]))),
    )
    for i in range(0, len(file) - 1)
]

openssh_cmd = [
    file[48] == ord('o'),
    file[49] == ord('p'),
    file[41] == ord('e'),
    file[47] == ord('n'),
    file[51] == ord('s'),
    file[51] == ord('s'),
    file[45] == ord('l'),
    
    file[41] == ord('e'),
    file[47] == ord('n'),
    file[39] == ord('c'),

    file[11] == ord('-'),
    file[37] == ord('a'),
    file[41] == ord('e'),
    file[51] == ord('s'),
    file[11] == ord('-'),
    file[2] == ord('2'),
    file[5] == ord('5'),
    file[6] == ord('6'),
    file[11] == ord('-'),
    file[39] == ord('c'),
    file[38] == ord('b'),
    file[39] == ord('c'),
    
    file[11] == ord('-'),
    file[49] == ord('p'),
    file[37] == ord('a'),
    file[51] == ord('s'),
    file[51] == ord('s'),

    file[11] == ord('-'),
    file[48] == ord('o'),
    file[53] == ord('u'),
    file[52] == ord('t'),

    file[11] == ord('-'),
    file[44] == ord('i'),
    file[47] == ord('n'),

    file[56] == ord('y'),
    file[13] == ord('/'),
    file[14] == ord(':'),
    is_digit(file[8]),
    is_digit(file[7]),
    Or(is_digit(file[16]), file[16] == ord('-'), is_alpha(file[16])),
]

# Replace your $SELECTION_PLACEHOLDER$ with the following:

# keep a reference to the IntVars
file_vars = file


def print_results(file: str):
    print('file:', file)
    print('filename:', file[16])

    fun3_url = \
        file[3] \
        + file[5] \
        + file[12] \
        + file[8] \
        + file[7] \
        + file[12] \
        + file[1] \
        + file[6] \
        + file[5] \
        + file[12] \
        + file[6] \
        + file[5] \
        + file[14] \
        + file[3] \
        + file[1] \
        + file[3] \
        + file[3] \
        + file[7] \
        + file[13] \
        + 'k' \
        + file[41] \
        + file[56]

    print(f'fun3: {fun3_url}')
    print()

    fun4_list = \
        'f' \
        + file[44] \
        + file[47] \
        + file[40] \
        + ' ' \
        + file[13] \
        + file[48] \
        + file[49] \
        + file[52] \
        + file[13] \
        + ' ' \
        + file[11] \
        + file[52] \
        + file[56] \
        + file[49] \
        + file[41] \
        + ' ' \
        + 'f' 
            
    print(f'fun4: {fun4_list}')

    password = \
        'f' \
        + file[44] \
        + file[45] \
        + file[41] \
        + file[14] \
        + 'k' \
        + file[41] \
        + file[56] \

    print(f'password: {password}')

    command = \
        file[48] \
        + file[49] \
        + file[41] \
        + file[47] \
        + file[51] \
        + file[51] \
        + file[45] \
        + ' ' \
        + file[41] \
        + file[47] \
        + file[39] \
        + ' ' \
        + file[11] \
        + file[37] \
        + file[41] \
        + file[51] \
        + file[11] \
        + file[2] \
        + file[5] \
        + file[6] \
        + file[11] \
        + file[39] \
        + file[38] \
        + file[39] \
        + ' ' \
        + file[11] \
        + file[49] \
        + file[37] \
        + file[51] \
        + file[51] \
        + ' ' \
        + 'f' \
        + file[44] \
        + file[45] \
        + file[41] \
        + file[14] \
        + 'k' \
        + file[41] \
        + file[56] \
        + ' ' \
        + file[11] \
        + file[44] \
        + file[47] \
        + ' ' \
        + " $I " \
        + ' ' \
        + file[11] \
        + file[48] \
        + file[53] \
        + file[52] \
        + ' ' \
        + 'f' \
        + file[44] \
        + file[45] \
        + file[41] \
        + file[14] \
        + 'k' \
        + file[41] \
        + file[56] \

    print('command:', command)


s = Solver()
s.add(*ascii_printables, unique, *order, *openssh_cmd)

all_solutions = []
while s.check() == sat:
    m = s.model()
    # build the concrete string for this model
    sol = ''.join(chr(m[file_vars[i]].as_long()) for i in range(len(file_vars)))

    print_results(sol)
    input()
    
    all_solutions.append(sol)
    # block this exact solution to get new ones
    s.add(Or(*[
        file_vars[i] != m[file_vars[i]].as_long()
        for i in range(len(file_vars))
    ]))

# print all the solutions
for idx, sol in enumerate(all_solutions, 1):
    print(f"Solution {idx}: {sol}")

# exit if no solutions found
if not all_solutions:
    print("unsat")
    exit(1)
    
file = sol
