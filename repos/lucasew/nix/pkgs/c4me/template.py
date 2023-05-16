#! /usr/bin/env nix-shell
#! nix-shell -p python3 -i python
from os import sys
from pathlib import Path

def reverse_txt(value):
    return value[::-1]

def eprint(*args, **kwargs):
    from sys import stderr
    print(*args, file=stderr, **kwargs)

def b64d(data):
    from base64 import b64decode
    decoded = b64decode(data)
    return decoded.decode('utf-8')

def b64e(data):
    from base64 import b64encode
    raw = bytes(data, 'utf-8')
    encoded = b64encode(raw)
    return encoded.decode('utf-8')

def urlencode(data):
    import urllib.parse
    return urllib.parse.quote_plus(data)

def urldecode(data):
    import urllib.parse
    return urllib.parse.unquote(data)

def debug_mode():
    return getenv("DEBUG") != None

def eval_print(stmt, globals=globals(), locals=locals()):
    if debug_mode():
        print("Run statement: ", stmt)
    print(eval(stmt, globals, locals))

def getenv(key):
    from os import environ
    return environ.get(key)

def is_match(regex, text):
    from re import finditer
    m = list(finditer(regex, text))
    return len(m) != 0

def simplex(num_vars, obj_type, obj, *restrictions):
    from fractions import Fraction
    from warnings import warn
    class Simplex(object):
        def __init__(self, num_vars, constraints, objective_function):
            """
            num_vars: Number of variables

            equations: A list of strings representing constraints
            each variable should be start with x followed by a underscore
            and a number
            eg of constraints
            ['1x_1 + 2x_2 >= 4', '2x_3 + 3x_1 <= 5', 'x_3 + 3x_2 = 6']
            Note that in x_num, num should not be more than num_vars.
            Also single spaces should be used in expressions.

            objective_function: should be a tuple with first element
            either 'min' or 'max', and second element be the equation
            eg 
            ('min', '2x_1 + 4x_3 + 5x_2')

            For solution finding algorithm uses two-phase simplex method
            """
            self.num_vars = num_vars
            self.constraints = constraints
            self.objective = objective_function[0]
            self.objective_function = objective_function[1]
            self.coeff_matrix, self.r_rows, self.num_s_vars, self.num_r_vars = self.construct_matrix_from_constraints()
            del self.constraints
            self.basic_vars = [0 for i in range(len(self.coeff_matrix))]
            self.phase1()
            r_index = self.num_r_vars + self.num_s_vars

            for i in self.basic_vars:
                if i > r_index:
                    raise ValueError("Infeasible solution")

            self.delete_r_vars()

            if 'min' in self.objective.lower():
                self.solution = self.objective_minimize()

            else:
                self.solution = self.objective_maximize()
            self.optimize_val = self.coeff_matrix[0][-1]
            self.print_coeff_matrix()

        def construct_matrix_from_constraints(self):
            num_s_vars = 0  # number of slack and surplus variables
            num_r_vars = 0  # number of additional variables to balance equality and less than equal to
            for expression in self.constraints:
                if '>=' in expression:
                    num_s_vars += 1

                elif '<=' in expression:
                    num_s_vars += 1
                    num_r_vars += 1

                elif '=' in expression:
                    num_r_vars += 1
            total_vars = self.num_vars + num_s_vars + num_r_vars

            coeff_matrix = [[Fraction("0") for i in range(total_vars+1)] for j in range(len(self.constraints)+1)]
            s_index = self.num_vars
            r_index = self.num_vars + num_s_vars
            r_rows = [] # stores the non -zero index of r
            for i in range(1, len(self.constraints)+1):
                constraint = self.constraints[i-1].split(' ')

                for j in range(len(constraint)):

                    if '_' in constraint[j]:
                        coeff, index = constraint[j].split('_')
                        if constraint[j-1] == '-':
                            coeff_matrix[i][int(index)-1] = Fraction("-" + coeff[:-1] + "")
                        else:
                            coeff_matrix[i][int(index)-1] = Fraction(coeff[:-1] + "")

                    elif constraint[j] == '<=':
                        coeff_matrix[i][s_index] = Fraction("1")  # add surplus variable
                        s_index += 1

                    elif constraint[j] == '>=':
                        coeff_matrix[i][s_index] = Fraction("-1")  # slack variable
                        coeff_matrix[i][r_index] = Fraction("1")   # r variable
                        s_index += 1
                        r_index += 1
                        r_rows.append(i)

                    elif constraint[j] == '=':
                        coeff_matrix[i][r_index] = Fraction("1")  # r variable
                        r_index += 1
                        r_rows.append(i)

                coeff_matrix[i][-1] = Fraction(constraint[-1] + "")

            return coeff_matrix, r_rows, num_s_vars, num_r_vars

        def phase1(self):
            # Objective function here is minimize r1+ r2 + r3 + ... + rn
            r_index = self.num_vars + self.num_s_vars
            for i in range(r_index, len(self.coeff_matrix[0])-1):
                self.coeff_matrix[0][i] = Fraction("-1")
            coeff_0 = 0
            for i in self.r_rows:
                self.coeff_matrix[0] = add_row(self.coeff_matrix[0], self.coeff_matrix[i])
                self.basic_vars[i] = r_index
                r_index += 1
            s_index = self.num_vars
            for i in range(1, len(self.basic_vars)):
                if self.basic_vars[i] == 0:
                    self.basic_vars[i] = s_index
                    s_index += 1

            # Run the simplex iterations
            key_column = max_index(self.coeff_matrix[0])
            condition = self.coeff_matrix[0][key_column] > 0

            while condition is True:

                key_row = self.find_key_row(key_column = key_column)
                self.basic_vars[key_row] = key_column
                pivot = self.coeff_matrix[key_row][key_column]
                self.normalize_to_pivot(key_row, pivot)
                self.make_key_column_zero(key_column, key_row)

                key_column = max_index(self.coeff_matrix[0])
                condition = self.coeff_matrix[0][key_column] > 0

        def find_key_row(self, key_column):
            min_val = float("inf")
            min_i = 0
            for i in range(1, len(self.coeff_matrix)):
                if self.coeff_matrix[i][key_column] > 0:
                    val = self.coeff_matrix[i][-1] / self.coeff_matrix[i][key_column]
                    if val <  min_val:
                        min_val = val
                        min_i = i
            if min_val == float("inf"):
                raise ValueError("Unbounded solution")
            if min_val == 0:
                warn("Dengeneracy")
            return min_i

        def normalize_to_pivot(self, key_row, pivot):
            for i in range(len(self.coeff_matrix[0])):
                self.coeff_matrix[key_row][i] /= pivot

        def make_key_column_zero(self, key_column, key_row):
            num_columns = len(self.coeff_matrix[0])
            for i in range(len(self.coeff_matrix)):
                if i != key_row:
                    factor = self.coeff_matrix[i][key_column]
                    for j in range(num_columns):
                        self.coeff_matrix[i][j] -= self.coeff_matrix[key_row][j] * factor

        def delete_r_vars(self):
            for i in range(len(self.coeff_matrix)):
                non_r_length = self.num_vars + self.num_s_vars + 1
                length = len(self.coeff_matrix[i])
                while length != non_r_length:
                    del self.coeff_matrix[i][non_r_length-1]
                    length -= 1

        def update_objective_function(self):
            objective_function_coeffs = self.objective_function.split()
            for i in range(len(objective_function_coeffs)):
                if '_' in objective_function_coeffs[i]:
                    coeff, index = objective_function_coeffs[i].split('_')
                    if objective_function_coeffs[i-1] == '-':
                        self.coeff_matrix[0][int(index)-1] = Fraction(coeff[:-1] + "")
                    else:
                        self.coeff_matrix[0][int(index)-1] = Fraction("-" + coeff[:-1] + "")

        def check_alternate_solution(self):
            for i in range(len(self.coeff_matrix[0])):
                if self.coeff_matrix[0][i] and i not in self.basic_vars[1:]:
                    warn("Alternate Solution exists")
                    break

        def objective_minimize(self):
            self.update_objective_function()

            for row, column in enumerate(self.basic_vars[1:]):
                if self.coeff_matrix[0][column] != 0:
                    self.coeff_matrix[0] = add_row(self.coeff_matrix[0], multiply_const_row(-self.coeff_matrix[0][column], self.coeff_matrix[row+1]))

            key_column = max_index(self.coeff_matrix[0])
            condition = self.coeff_matrix[0][key_column] > 0

            while condition == True:

                key_row = self.find_key_row(key_column = key_column)
                self.basic_vars[key_row] = key_column
                pivot = self.coeff_matrix[key_row][key_column]
                self.normalize_to_pivot(key_row, pivot)
                self.make_key_column_zero(key_column, key_row)

                key_column = max_index(self.coeff_matrix[0])
                condition = self.coeff_matrix[0][key_column] > 0

            solution = {}
            for i, var in enumerate(self.basic_vars[1:]):
                if var < self.num_vars:
                    solution['x_'+str(var+1)] = self.coeff_matrix[i+1][-1]

            for i in range(0, self.num_vars):
                if i not in self.basic_vars[1:]:
                    solution['x_'+str(i+1)] = Fraction("0")
            self.check_alternate_solution()
            return solution

        def objective_maximize(self):
            self.update_objective_function()

            for row, column in enumerate(self.basic_vars[1:]):
                if self.coeff_matrix[0][column] != 0:
                    self.coeff_matrix[0] = add_row(self.coeff_matrix[0], multiply_const_row(-self.coeff_matrix[0][column], self.coeff_matrix[row+1]))

            key_column = min_index(self.coeff_matrix[0])
            condition = self.coeff_matrix[0][key_column] < 0

            while condition == True:

                key_row = self.find_key_row(key_column = key_column)
                self.basic_vars[key_row] = key_column
                pivot = self.coeff_matrix[key_row][key_column]
                self.normalize_to_pivot(key_row, pivot)
                self.make_key_column_zero(key_column, key_row)

                key_column = min_index(self.coeff_matrix[0])
                condition = self.coeff_matrix[0][key_column] < 0

            solution = {}
            for i, var in enumerate(self.basic_vars[1:]):
                if var < self.num_vars:
                    solution['x_'+str(var+1)] = self.coeff_matrix[i+1][-1]

            for i in range(0, self.num_vars):
                if i not in self.basic_vars[1:]:
                    solution['x_'+str(i+1)] = Fraction("0")
            self.check_alternate_solution()

            return solution
        def print_coeff_matrix(self):
            for line in self.coeff_matrix:
                eprint(line)

    def add_row(row1, row2):
        row_sum = [0 for i in range(len(row1))]
        for i in range(len(row1)):
            row_sum[i] = row1[i] + row2[i]
        return row_sum

    def max_index(row):
        max_i = 0
        for i in range(0, len(row)-1):
            if row[i] > row[max_i]:
                max_i = i

        return max_i

    def multiply_const_row(const, row):
        mul_row = []
        for i in row:
            mul_row.append(const*i)
        return mul_row

    def min_index(row):
        min_i = 0
        for i in range(0, len(row)):
            if row[min_i] > row[i]:
                min_i = i

        return min_i

    s = Simplex(int(num_vars), restrictions, (obj_type, obj))
    return s.solution

def pad_bin(number, zfill = 8):
    return bin(number).__str__()[2:].zfill(zfill)

def is_binary_expr(expr):
    for c in expr:
        if c not in ["0", "1"]:
            return False
    return True

def parse_binary_expr(expr):
    if is_binary_expr(expr):
        return eval("0b%s" %(expr))
    raise TypeError("'%s' is not a binary expression", expr)

class IP():
    def __init__(self, expr, try_binary = False):
        if type(expr) == list and len(expr) == 4:
            self._ip = [int(str(v)) for v in expr]
            self._validate_input()
            return
        if type(expr) == int:
            expr = pad_bin(expr, zfill = 32)
        if type(expr) == str and len(expr) == 32:
            new_expr = []
            for i in range(0, 32):
                if i in [8, 16, 24]:
                    new_expr.append(".")
                new_expr.append(expr[i])
            expr = "".join(new_expr)
            try_binary = True
        if type(expr) == str:
            dotsplit = expr.split(".")
            if len(dotsplit) == 4:
                ip = []
                for part in dotsplit:
                    if is_binary_expr(part) and try_binary:
                        ip.append(parse_binary_expr(part))
                    else:
                        ip.append(int(part))
                self._ip = ip
                self._validate_input()
                return
        raise TypeError("not a valid input for IP")

    def _validate_input(self):
        for val in self._ip:
            if val > 255 or val < 0:
                raise TypeError("value must be between 0 and 255 but its %s" %(val))

    def bin_repr(self):
        r = []
        for octet in self._ip:
            r.append(pad_bin(octet))
        return ".".join(r)

    def bin_stream(self):
        return self.bin_repr().replace(".", "")

    def __int__(self):
        return parse_binary_expr(self.bin_stream())

    def is_mask(self):
        chars = self.bin_stream()
        if chars[0] == "0": # Máscaras não começam com 0
            return False
        justOnes = True # A ideia aqui é tipo implementar um automato
        for ch in chars:
            if justOnes and (not chars == "1"):
                justOnes = False
                continue
            if (not justOnes) and chars == "1":
                return False
        return True

    def mask_number_hosts(self):
        if self.is_mask():
            s = self.bin_stream()
            bits = 0
            for c in s:
                if c == "0":
                    bits += 1
            return (2**bits) - 2
        raise TypeError("%s is not a mask", self.__repr__())

    def mask_number_nets(self):
        if self.is_mask():
            s = self.bin_stream()
            bits = 0
            for c in s:
                if c == "1":
                    bits += 1
            return (2**bits)
        raise TypeError("%s is not a mask", self.__repr__())

    def get_class(self):
        [a, b, c, d] = self._ip
        if a <= 127:
            return "A"
        elif a <= 191:
            return "B"
        elif a <= 223:
            return "C"
        elif a <= 239:
            return "MULTICAST"
        elif a <= 255:
            return "EXPERIMENTAL"

    def classful_mask(self):
        cls = self.get_class()
        if cls == "A":
            return IP("255.0.0.0")
        if cls == "B":
            return IP("255.255.0.0")
        if cls == "C":
            return IP("255.255.255.0")

    def classful_netid(self):
        cls = self.get_class()
        if cls == "A":
            return "%d/8" %(self._ip[0])
        if cls == "B":
            return "%s/16" %(".".join([str(s) for s in self._ip[0:2]]))
        if cls == "C":
            return "%s/24" %(".".join([str(s) for s in self._ip[0:3]]))

    def __xor__(self, another):
        return IP(int(self) ^ int(another))

    def __and__(self, another):
        return IP(int(self) & int(another))
    def __str__(self):
        return ".".join([str(s) for s in self._ip])
    def __repr__(self):
        cls = self.get_class()
        return "<IP(%s): %s>" %(cls, str(self))

def subrede(level):
    if type(level) == int and level > 0 and level < 32:
        ones = level
        zeroes = 32 - level
        from itertools import repeat
        ret = []
        for i in range(0, 32):
            if i in [8, 16, 24]:
                ret.append(".")
            if i < level:
                ret.append("1")
            else:
                ret.append("0")
        return IP("".join(ret), try_binary = True)

def meu_ip():
    from urllib.request import urlopen
    with urlopen("http://ifconfig.me") as response:
        return IP(response.read().decode('utf-8'))

def benchmark(iters, fn, *args):
    assert type(iters) == int
    from timeit import timeit
    def call(fn, *args):
        return lambda: fn(*args)
    return timeit(call(fn, *args), number=iters)


def frac(*args):
    from fractions import Fraction
    return Fraction(*args)

def is_list(e):
    return type(e) == list

def expand_list(*elems):
    return list(elems)

def inspect(*elems):
    return elems

def sort(elems, **args):
    elems = list(elems)
    elems.sort(**args)
    return elems

def reverse(elems):
    elems = list(elems)
    elems.reverse()
    return elems

def get_args():
    from sys import argv
    return argv[1:]

def eval_passed_stmt():
    args = get_args()
    if len(args) == 0:
        print("c4me [python expression]")
        exit(1)
        return
    elif args[0] == "stdin":
        return
    elif args[0] == "repl":
        repl()
    elif is_match(r"^[-0-9]", args[0]):
        eval_print(" ".join(args))
    elif is_match(r"^.*\(", args[0]):
        eval_print(" ".join(args))
    elif not is_match(r"^.*\(", args[0]):
        [fn, *args] = args
        eval_print("%s(*args)" %(fn), globals(), locals())
    elif len(args) == 1:
        eval_print(args[0])

def repl():
    import readline, rlcompleter
    from code import InteractiveConsole
    readline.parse_and_bind("tab: complete")
    InteractiveConsole(globals()).interact()

def main():
    eval_passed_stmt()
