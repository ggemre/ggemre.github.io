#import "template.typ": *

#show: project.with(
  title: "Gene Sequencing",
  authors: (
    "Gage Moore",
  ),
  date: "November 5, 2023",
)

= Introduction
This project utilizes dynamic programming in order to calculate the minimal cost of aligning gene sequences and extracting the optimal alignments of those sequences.

= Efficiency
The sequencing program was implemented in two different manners: an unrestricted version and a banded version. The unrestricted algorithm calculates scores for each pair of sequences across the entire data set. The banded algorithm is given a boundary that it stays within, skipping any distances that exceed that boundary. This is to improve overall runtime when computing distances, however it impacts accuracy.

== Unrestricted Algorithm
The following function is used to create the value and back pointer tables for the unrestricted version of the algorithm:

```py
def unrestricted_create_tables(self, num_rows, num_cols):
        val_table = [i[:] for i in [[math.inf]*(num_cols)]*(num_rows+1)] # O(n)
        back_table = [i[:] for i in [[0]*(num_cols)]*(num_rows+1)] # O(n)

        for i in range(num_rows): # O(n)
            val_table[i][0] = i * INDEL
            back_table[i][0] = 4 

        for i in range(num_cols): # O(m)
            val_table[0][i] = i * INDEL
            back_table[0][i] = 2

        back_table[0][0] = 1

        return val_table, back_table
```

The function iterates through the first values of every row and the first values of every column in order to initalize the tables used by the algorithm. As a result, it runs in $O(n+m)$ time, where the number of rows corresponds to the length of the first sequence, $n$, and the number of columns corresponds to the length of the second, $m$. The space complexity is $O(2(n times m))$, reduced to $O(n times m)$, because the function fills in two $n times m$ two-dimensional lists.

The next function is used to fill in the two tables that were intialized:

```py
def unrestricted_fill_tables(self, seq1, seq2, val_table, back_table, num_rows, num_cols):
        for i in range(1, num_rows): # O(nm)
            for j in range(1, num_cols):
                left_ins_cost = INDEL+val_table[i][j-1]
                # Check if current chars match & update diagonal cost accordingly
                if seq1[i-1] == seq2[j-1]:
                    diag_subanded_cost = MATCH+val_table[i-1][j-1]
                else:
                    diag_subanded_cost = SUB+val_table[i-1][j-1]
                
                up_del_cost = INDEL+val_table[i-1][j]

                if left_ins_cost <= diag_subanded_cost and left_ins_cost <= up_del_cost:
                    val_table[i][j] = left_ins_cost
                    back_table[i][j] = 2
                elif up_del_cost < left_ins_cost and up_del_cost <= diag_subanded_cost:
                    val_table[i][j] = up_del_cost
                    back_table[i][j] = 4
                else:
                    back_table[i][j] = 3
                    val_table[i][j] = diag_subanded_cost

        return val_table, back_table
```

The function iterates through every cell in the table, left to right from top to bottom, updating the table values according to given constant cost values. Because the function hits every cell, (aside from the first initialized row & column), it runs in $O(n times m)$ time. The tables are passed into the function as parameters, and because the function does not expand them or dynamically allocate any additional space, the space complexity of the entire function is $O(1)$.

With the tables filled in, the following function is used to determine the alignment strings of the two sequences:

```py
def unrestricted_find_alignments(self, seq1, seq2, back_table, num_rows, num_cols):
        cur_row = num_rows-1
        cur_col = num_cols-1
        back_ptr = back_table[cur_row][cur_col]
        alignment1 = ""
        alignment2 = ""

        # Generate alignment strings
        while back_ptr != 1: # O(n+m) worst case
            if back_ptr == 2:
                alignment1 = "-" + alignment1
                alignment2 = seq2[cur_col-1] + alignment2
                cur_col -= 1
            elif back_ptr == 3:
                alignment1 = seq1[cur_row-1] + alignment1
                alignment2 = seq2[cur_col-1] + alignment2
                cur_row -= 1
                cur_col -= 1
            elif back_ptr == 4:
                alignment1 = seq1[cur_row-1] + alignment1
                alignment2 = "-" + alignment2
                cur_row -= 1

            back_ptr = back_table[cur_row][cur_col]

        return alignment1, alignment2
```

In determining the alignment strings, the function will run in $O(n+m)$ time because at its worst case it will need to iterate through every character of the first sequence, $n$, and every character of the second sequence, $m$. The space complexity is also $O(n+m)$ because the strings to hold the alignment values, `alignment1` and `alignment2`, will grow to hold $n$ elements and $m$ elements respectively. 

The unrestricted algorithm can be called from this entry function:

```py
def solve_unrestricted(self, seq1, seq2):
        num_rows = len(seq1)+1
        num_cols = len(seq2)+1

        val_table, back_table = self.unrestricted_create_tables(num_rows, num_cols) # O(n+m)
        val_table, back_table = self.unrestricted_fill_tables(seq1, seq2, val_table, back_table, num_rows, num_cols) # O(nm)

        score = val_table[num_rows-1][num_cols-1]

        alignment1, alignment2 = self.unrestricted_find_alignments(seq1, seq2, back_table, num_rows, num_cols) # O(n+m)

        return score, alignment1[:100], alignment2[:100]
```

The main unrestricted function calls the functions mentioned above in sequence. It initializes the tables, $O(n+m)$, fills them dynamically, $O(n times m)$, and generates the alignments from that, $O(n+m)$. Overall, the function is bounded by its most time-complex component, in this case it is $O(n times m)$. Similarily, the space complexity is $O(2(n times m))$, reduced to $O(n times m)$, because the tables are created within this function.

== Banded Algorithm
The following function is used to create the value and back pointer tables for the banded version of the algorithm:

```py
def banded_create_tables(self, num_rows, num_cols):
        val_table = [i[:] for i in [[math.inf]*(num_cols)]*(num_rows+1)] # O(n)
        back_table = [i[:] for i in [[0]*(num_cols)]*(num_rows+1)] # O(n)

        for i in range(0, MAXINDELS): # O(k)
            val_table[MAXINDELS-i][i] = (MAXINDELS-i) * INDEL
            back_table[MAXINDELS-i][i] = 4

        for i in range(MAXINDELS, num_cols): # O(n-k)
            val_table[0][i] = (i-MAXINDELS) * INDEL
            back_table[0][i] = 2

        back_table[0][MAXINDELS] = 1

        return val_table, back_table
```

The function involves a series of `for` loops in order to create and initialize the value and back pointer tables. The overall time complexity can be evaluated by adding up the complexity of each of these loops, $O(n+n+k+(n-k))$, which can ultimately be simplified to $O(n)$. The space complexity is $O(2(k times n)$, reduced to $O(k times n)$, because the function creates two tables, each having the dimension $k times n$.

The next function is used to fill these tables dynamically:

```py
def banded_fill_tables(self, seq1, seq2, val_table, back_table, num_rows, num_cols):
        MAX_IDX_SUM = len(seq2) + MAXINDELS + 1

        for i in range(1, num_rows): # O(kn)
            for j in range(0, num_cols):
                # If out of bounds, skip iteration
                if i + j <= MAXINDELS or i + j >= MAX_IDX_SUM:
                    continue

                left_ins_cost = math.inf
                if j > 0:
                    left_ins_cost = INDEL + val_table[i][j-1]
                diag_subanded_cost = math.inf
                if i > 0:
                    # Check if current chars match & update diagonal cost accordingly
                    if seq1[i-1] == seq2[i + j + -MAXINDELS - 1]:
                        diag_subanded_cost = MATCH+val_table[i-1][j]
                    else:
                        diag_subanded_cost = SUB+val_table[i-1][j]
                    
                up_del_cost = math.inf
                if j + 1 < num_cols and i > 0:
                    up_del_cost = INDEL + val_table[i-1][j+1]

                if left_ins_cost <= diag_subanded_cost and left_ins_cost <= up_del_cost:
                    val_table[i][j] = left_ins_cost
                    back_table[i][j] = 2
                elif up_del_cost < left_ins_cost and up_del_cost <= diag_subanded_cost:
                    val_table[i][j] = up_del_cost
                    back_table[i][j] = 4
                else:
                    back_table[i][j] = 3
                    val_table[i][j] = diag_subanded_cost

        return val_table, back_table
```

The function iterates through every cell in the table, left to right from top to bottom, updating the table values according to given constant cost values. Because the function hits every cell, (aside from the first initialized row & column), it runs in $O(k times n)$ time. The tables are passed into the function as parameters, and because the function does not expand them or dynamically allocate any additional space, the space complexity of the entire function is $O(1)$.

With the tables filled in, the following function is used to determine the alignment strings of the two sequences:

```py
def banded_find_alignments(self, seq1, seq2, back_table, score_i, score_j):
        cur_row = score_i
        cur_col = score_j
        back_ptr = back_table[cur_row][cur_col]
        alignment1 = ""
        alignment2 = ""
        seq2_idx = len(seq2)-1

        # Generate alignment strings
        while back_ptr != 1: # O(k+n) worst case
            if back_ptr == 2:
                alignment1 = "-" + alignment1
                alignment2 = seq2[seq2_idx] + alignment2
                cur_col -= 1
            elif back_ptr == 3:
                alignment1 = seq1[cur_row-1] + alignment1
                alignment2 = seq2[seq2_idx] + alignment2
                cur_row -= 1
            elif back_ptr == 4:
                alignment1 = seq1[cur_row-1] + alignment1
                alignment2 = "-" + alignment2
                cur_row -= 1
                cur_col += 1

            back_ptr = back_table[cur_row][cur_col]
            seq2_idx -= 1

        return alignment1, alignment2
```

In determining the alignment strings, the function will run in $O(n+m)$ time because at its worst case it will need to iterate through every character of the first sequence, $n$, and every character of the second sequence, $m$. The space complexity is also $O(n+m)$ because the strings to hold the alignment values, `alignment1` and `alignment2`, will grow to hold $n$ elements and $m$ elements respectively. 

The banded algorithm can be called from this entry function:

```py
def solve_banded(self, seq1, seq2):
        if abs(len(seq1) - len(seq2)) > MAXINDELS:
            return math.inf, "No Alignment Possible", "No Alignment Possible"

        num_rows = len(seq1)+1
        num_cols = 2 * MAXINDELS + 1

        val_table, back_table = self.banded_create_tables(num_rows, num_cols) # O(n)
        val_table, back_table = self.banded_fill_tables(seq1, seq2, val_table, 
          back_table, num_rows, num_cols) # O(kn)

        score = 0
        score_i = 0
        score_j = 0
        if len(seq1) == len(seq2):
            score_i = num_rows-1
            score_j = 3
            score = val_table[score_i][score_j]
        if (len(seq1) + 1) == len(seq2):
            score_i = num_rows-1
            score_j = 4
            score = val_table[score_i][score_j]

        alignment1, alignment2 = self.banded_find_alignments(seq1, seq2, back_table, score_i, score_j) # O(n+m)

        return score, alignment1[:100], alignment2[:100]
```

It calls the functions mentioned above in sequence. It initializes the tables, $O(n)$, fills them dynamically, $O(k times n)$, and generates the alignments from that, $O(n+m)$. Overall, the function is bounded by its most time-complex component, in this case it is $O(k times n)$. Similarily, the space complexity is $O(2(k times n))$, reduced to $O(k times n)$, because the tables are created within this function.

\ \ \
== Main Alignment Function
The following function is used to call either one of the algorithms explored above.

```py
def align(self, seq1, seq2, banded, align_length):
        self.banded = banded
        self.MaxCharactersToAlign = align_length

        # Truncate sequences if they are too long
        if len(seq1) > self.MaxCharactersToAlign:
            seq1 = seq1[:self.MaxCharactersToAlign]
        if len(seq2) > self.MaxCharactersToAlign:
            seq2 = seq2[:self.MaxCharactersToAlign]

        # Call appropriate alignment function
        if banded:
            score, alignment1, alignment2 = self.solve_banded(seq1, seq2) # O(kn)
        else:
            score, alignment1, alignment2 = self.solve_unrestricted(seq1, seq2) # O(nm)

        return {"align_cost": score, "seqi_first100": alignment1, "seqj_first100": alignment2}
```

The significant point of the function is to call either the banded algorithm or the unrestricted algorithm. Depending on which is invoked, the function will run in either $O(k times n)$ or $O(n times m)$ time. Because the unrestricted algorithm serves as an upper bound for the banded algorithm, $"solve_banded()" = O("solve_unrestricted")$, so the time complexity of this program can be expressed as $O(n times m)$. The space compelxity is $O(n times m)$ in order to manage the creation of the tables.

\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \
= Example Usage

#image("unrestricted1000.png")
#image("banded3000.png")

\ \
Below, the alignments for sequences *\#3* and *\#10* are given for the first 100 characters. First, generated via the unrestricted algorithm at `n=1000`, and second with the banded algorithm at `n=3000`.

\ \ 
*Alignment of sequences \#3 and \#10, (unrestricted, n=1000, first 100 chars):*

#place(
  `gattgcgagcgatttgcgtgcgtgcatcccgcttc-actg--at-`,
  dx: -40pt,
  dy: 5pt
)
#place(
  `ctcttgttagatcttttcataatctaaactttataaaaacatccactccctgta-`,
  dx: 198.5pt,
  dy: 5pt
)
#place(
  `-ataa-gagtgattggcgtccgtacgtaccctttctactctcaaactcttgttagtttaaatc-taatctaaactttataaa--`,
  dx: -40pt,
  dy: 15pt
)
#place(
  `cggc-acttcctgtgt`,
  dx: 405pt,
  dy: 15pt
)

\ \ \
*Alignment of sequences \#3 and \#10, (banded, n=3000, first 100 chars):*

#place(
  `gattgcgagcgatttgcgtgcgtgcatcccgcttc-actg--at-`,
  dx: -40pt,
  dy: 12pt
)

#place(
  `ctcttgttagatcttttcataatctaaactttataaaaacatccactccctgta-`,
  dx: 198.5pt,
  dy: 12pt
)

#place(
  `-gttt-tgctttacttaataggttggcagaagattatgtctacctctttgatgagggaggcga-gataagagtgattggcgt--`,
  dx: -40pt,
  dy: 22pt
)

#place(
  `gtac-taccctttcta`,
  dx: 405pt,
  dy: 22pt
)

\ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \  \
= Full Source Code
The entire program is included in full below.

```py
#!/usr/bin/python3

from which_pyqt import PYQT_VER
if PYQT_VER == 'PYQT5':
	from PyQt5.QtCore import QLineF, QPointF
elif PYQT_VER == 'PYQT4':
	from PyQt4.QtCore import QLineF, QPointF
elif PYQT_VER == 'PYQT6':
	from PyQt6.QtCore import QLineF, QPointF
else:
	raise Exception('Uns4ported Version of PyQt: {}'.format(PYQT_VER))

import math

# Used to compute the bandwidth for banded version
MAXINDELS = 3

# Used to implement Needleman-Wunsch scoring
MATCH = -3
INDEL = 5
SUB = 1

class GeneSequencing:
    def __init__(self):
        pass

    '''
    Initialize value and back pointer tables for num_rows and num_cols.
    Time Complexity: O(n+m)
    Space Complexity: O(2nm)
    '''
    def unrestricted_create_tables(self, num_rows, num_cols):
        val_table = [i[:] for i in [[math.inf]*(num_cols)]*(num_rows+1)] # O(n)
        back_table = [i[:] for i in [[0]*(num_cols)]*(num_rows+1)] # O(n)

        for i in range(num_rows): # O(n)
            val_table[i][0] = i * INDEL
            back_table[i][0] = 4 

        for i in range(num_cols): # O(m)
            val_table[0][i] = i * INDEL
            back_table[0][i] = 2

        back_table[0][0] = 1

        return val_table, back_table

    '''
    Dynamically fill out the value and back pointer tables.
    Time Complexity: O(nm)
    Space Complexity: O(1)
    '''
    def unrestricted_fill_tables(self, seq1, seq2, val_table, back_table, num_rows, num_cols):
        for i in range(1, num_rows): # O(nm)
            for j in range(1, num_cols):
                left_ins_cost = INDEL+val_table[i][j-1]
                # Check if current chars match & update diagonal cost accordingly
                if seq1[i-1] == seq2[j-1]:
                    diag_subanded_cost = MATCH+val_table[i-1][j-1]
                else:
                    diag_subanded_cost = SUB+val_table[i-1][j-1]
                
                up_del_cost = INDEL+val_table[i-1][j]

                if left_ins_cost <= diag_subanded_cost and left_ins_cost <= up_del_cost:
                    val_table[i][j] = left_ins_cost
                    back_table[i][j] = 2
                elif up_del_cost < left_ins_cost and up_del_cost <= diag_subanded_cost:
                    val_table[i][j] = up_del_cost
                    back_table[i][j] = 4
                else:
                    back_table[i][j] = 3
                    val_table[i][j] = diag_subanded_cost

        return val_table, back_table

    '''
    Calculate the alignments for seq1 and seq2.
    Time Complexity: O(n+m)
    Space Complexity: O(n+m)
    '''
    def unrestricted_find_alignments(self, seq1, seq2, back_table, num_rows, num_cols):
        cur_row = num_rows-1
        cur_col = num_cols-1
        back_ptr = back_table[cur_row][cur_col]
        alignment1 = ""
        alignment2 = ""

        # Generate alignment strings
        while back_ptr != 1: # O(n+m) worst case
            if back_ptr == 2:
                alignment1 = "-" + alignment1
                alignment2 = seq2[cur_col-1] + alignment2
                cur_col -= 1
            elif back_ptr == 3:
                alignment1 = seq1[cur_row-1] + alignment1
                alignment2 = seq2[cur_col-1] + alignment2
                cur_row -= 1
                cur_col -= 1
            elif back_ptr == 4:
                alignment1 = seq1[cur_row-1] + alignment1
                alignment2 = "-" + alignment2
                cur_row -= 1

            back_ptr = back_table[cur_row][cur_col]

        return alignment1, alignment2

    '''
    Main function for solving the unrestricted version of the problem.
    Time Complexity: O(nm)
    Space Complexity: O(2nm)
    '''
    def solve_unrestricted(self, seq1, seq2):
        num_rows = len(seq1)+1
        num_cols = len(seq2)+1

        val_table, back_table = self.unrestricted_create_tables(num_rows, num_cols) # O(n+m)
        val_table, back_table = self.unrestricted_fill_tables(seq1, seq2, val_table, back_table, num_rows, num_cols) # O(nm)

        score = val_table[num_rows-1][num_cols-1]

        alignment1, alignment2 = self.unrestricted_find_alignments(seq1, seq2, back_table, num_rows, num_cols) # O(n+m)

        return score, alignment1[:100], alignment2[:100]

    '''
    Initialize value and back pointer tables for num_rows and num_cols.
    Time Complexity: O(n)
    Space Complexity: O(2kn)
    '''
    def banded_create_tables(self, num_rows, num_cols):
        val_table = [i[:] for i in [[math.inf]*(num_cols)]*(num_rows+1)] # O(n)
        back_table = [i[:] for i in [[0]*(num_cols)]*(num_rows+1)] # O(n)

        for i in range(0, MAXINDELS): # O(k)
            val_table[MAXINDELS-i][i] = (MAXINDELS-i) * INDEL
            back_table[MAXINDELS-i][i] = 4

        for i in range(MAXINDELS, num_cols): # O(n-k)
            val_table[0][i] = (i-MAXINDELS) * INDEL
            back_table[0][i] = 2

        back_table[0][MAXINDELS] = 1

        return val_table, back_table

    '''
    Dynamically fill out the value and back pointer tables.
    Time Complexity: O(kn)
    Space Complexity: O(kn)
    '''
    def banded_fill_tables(self, seq1, seq2, val_table, back_table, num_rows, num_cols):
        MAX_IDX_SUM = len(seq2) + MAXINDELS + 1

        for i in range(1, num_rows): # O(kn)
            for j in range(0, num_cols):
                # If out of bounds, skip iteration
                if i + j <= MAXINDELS or i + j >= MAX_IDX_SUM:
                    continue

                left_ins_cost = math.inf
                if j > 0:
                    left_ins_cost = INDEL + val_table[i][j-1]
                diag_subanded_cost = math.inf
                if i > 0:
                    # Check if current chars match & update diagonal cost accordingly
                    if seq1[i-1] == seq2[i + j + -MAXINDELS - 1]:
                        diag_subanded_cost = MATCH+val_table[i-1][j]
                    else:
                        diag_subanded_cost = SUB+val_table[i-1][j]
                    
                up_del_cost = math.inf
                if j + 1 < num_cols and i > 0:
                    up_del_cost = INDEL + val_table[i-1][j+1]

                if left_ins_cost <= diag_subanded_cost and left_ins_cost <= up_del_cost:
                    val_table[i][j] = left_ins_cost
                    back_table[i][j] = 2
                elif up_del_cost < left_ins_cost and up_del_cost <= diag_subanded_cost:
                    val_table[i][j] = up_del_cost
                    back_table[i][j] = 4
                else:
                    back_table[i][j] = 3
                    val_table[i][j] = diag_subanded_cost

        return val_table, back_table

    '''
    Calculate the alignments for seq1 and seq2.
    Time Complexity: O(n+m)
    Space Complexity: O(n+m)
    '''
    def banded_find_alignments(self, seq1, seq2, back_table, score_i, score_j):
        cur_row = score_i
        cur_col = score_j
        back_ptr = back_table[cur_row][cur_col]
        alignment1 = ""
        alignment2 = ""
        seq2_idx = len(seq2)-1

        # Generate alignment strings
        while back_ptr != 1: # O(n+m) worst case
            if back_ptr == 2:
                alignment1 = "-" + alignment1
                alignment2 = seq2[seq2_idx] + alignment2
                cur_col -= 1
            elif back_ptr == 3:
                alignment1 = seq1[cur_row-1] + alignment1
                alignment2 = seq2[seq2_idx] + alignment2
                cur_row -= 1
            elif back_ptr == 4:
                alignment1 = seq1[cur_row-1] + alignment1
                alignment2 = "-" + alignment2
                cur_row -= 1
                cur_col += 1

            back_ptr = back_table[cur_row][cur_col]
            seq2_idx -= 1

        return alignment1, alignment2

    '''
    Main function for solving the banded version of the problem.
    Time Complexity: O(kn)
    Space Complexity: O(2kn)
    '''
    def solve_banded(self, seq1, seq2):
        if abs(len(seq1) - len(seq2)) > MAXINDELS:
            return math.inf, "No Alignment Possible", "No Alignment Possible"

        num_rows = len(seq1)+1
        num_cols = 2 * MAXINDELS + 1

        val_table, back_table = self.banded_create_tables(num_rows, num_cols) # O(n)
        val_table, back_table = self.banded_fill_tables(seq1, seq2, val_table, 
          back_table, num_rows, num_cols) # O(kn)

        score = 0
        score_i = 0
        score_j = 0
        if len(seq1) == len(seq2):
            score_i = num_rows-1
            score_j = 3
            score = val_table[score_i][score_j]
        if (len(seq1) + 1) == len(seq2):
            score_i = num_rows-1
            score_j = 4
            score = val_table[score_i][score_j]

        alignment1, alignment2 = self.banded_find_alignments(seq1, seq2, back_table, score_i, score_j) # O(n+m)

        return score, alignment1[:100], alignment2[:100]
    
    '''
    This is the method called by the GUI.  _seq1_ and _seq2_ are two sequences to be aligned, _banded_ is a boolean that tells
    you whether you should compute a banded alignment or full alignment, and _align_length_ tells you
    how many base pairs to use in computing the alignment.
    Time Complexity: O(nm) or O(kn) depending on banded
    Space Complexity: O(2nm) or O(2kn) depending on banded
    '''
    def align(self, seq1, seq2, banded, align_length):
        self.banded = banded
        self.MaxCharactersToAlign = align_length

        # Truncate sequences if they are too long
        if len(seq1) > self.MaxCharactersToAlign:
            seq1 = seq1[:self.MaxCharactersToAlign]
        if len(seq2) > self.MaxCharactersToAlign:
            seq2 = seq2[:self.MaxCharactersToAlign]

        # Call appropriate alignment function
        if banded:
            score, alignment1, alignment2 = self.solve_banded(seq1, seq2) # O(kn)
        else:
            score, alignment1, alignment2 = self.solve_unrestricted(seq1, seq2) # O(nm)

        return {"align_cost": score, "seqi_first100": alignment1, "seqj_first100": alignment2}
    
```