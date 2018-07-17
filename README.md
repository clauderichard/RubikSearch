# RubikSearch
Some Julia modules to search for Rubik's cube algorithms

## 2x2x2 Blindfolded algorithms

In the file R2.jl, there's a method to look for 2x2x2 algorithms.
The intention is to find algorithms that can be used for a strategy for a fast blindfolded solve.
So each algorithm will affect only two of the eight pieces in the cube, and leave the others intact.

Use it as follows from a Julia command line.
The result is also shown here, from when I ran it on June 26th 2018.

```
julia> include("R2.jl")
julia> R2.algs8(5)
AR :  U' R' U  R' F  U' R  U  F2 R2  ( 1t' 2t ) ( 10 moves ) ( inconvenience level 27 )
AS1:  U2 F  R  F' U  R2 U' R  U  R2  ( 1t 2t' 1->2 ) ( 10 moves ) ( inconvenience level 27 )
AS2:  NOT FOUND
DR :  R  U2 R' U  R2 U' R2 U  R' U2  ( 1t 7t' ) ( 10 moves ) ( inconvenience level 24 )
DS1:  NOT FOUND
DS2:  U' F' R2 U2 R' F' U  R2 U' R   ( 1t 7t' 1->7 ) ( 10 moves ) ( inconvenience level 27 )
OR :  R  U2 R' U2 R  U' R2 U  R2 U'  ( 2t' 7t ) ( 10 moves ) ( inconvenience level 24 )
OS1:  F' U' R  U2 R' U  F' R' F2 U2  ( 2->7 ) ( 10 moves ) ( inconvenience level 30 )
OS2:  U' R' U  R2 U' F  R' F' U2 R2  ( 2t' 7t 2->7 ) ( 10 moves ) ( inconvenience level 27 )

julia> R2.algs8(6)
AR :  U' R' U  R' U  R' U  R  U' R  U' R   ( 1t 2t' ) ( 12 moves ) ( inconvenience level 24 )
AS1:  U2 F  R  F' U  R2 U' R  U  R2  ( 1t 2t' 1->2 ) ( 10 moves ) ( inconvenience level 27 )
AS2:  F  R' U2 R2 U' F  U  R2 U  R2 U   ( 1->2 ) ( 11 moves ) ( inconvenience level 30 )
DR :  U2 R  U' R2 U  R2 U' R  U2 R'  ( 1t' 7t ) ( 10 moves ) ( inconvenience level 24 )
DS1:  F2 R  U' R  U  R' F2 R' U' R' U   ( 1->7 ) ( 11 moves ) ( inconvenience level 30 )
DS2:  U' F' R2 U2 R' F' U  R2 U' R   ( 1t 7t' 1->7 ) ( 10 moves ) ( inconvenience level 27 )
OR :  U  R' U  R  U' R  U' R  U' R' U  R'  ( 2t 7t' ) ( 12 moves ) ( inconvenience level 24 )
OS1:  U2 F2 R  F  U' R  U2 R' U  F   ( 2->7 ) ( 10 moves ) ( inconvenience level 30 )
OS2:  U' R' U  R2 U' F  R' F' U2 R2  ( 2t' 7t 2->7 ) ( 10 moves ) ( inconvenience level 27 )
```

The argument to R2.algs8 means half of the maximum number of moves in each algorithm.
So if you pass 5 as an argument, it looks for algorithms of 10 moves or less.

It only looks for algorithms that leave 6 of the pieces intact, and modifies the other 2 pieces somehow.
There are 8 qualitatively-different ways that you can affect only 2 pieces with an algorithm.
Each of those 8 algorithms can be either mirrored about some axis of symmetry, rotated by substituting which faces to turn,
or a combination of those two, to make any other modification of 2 pieces on the cube.
So essentially, each of the following 8 makes a different "kind" of effect on the 2x2x2 cube.
- AR : adjacent rotation-only. Two pieces adjacent to each other get rotated in place, they don't switch with each other.
- AS1: adjacent switch 1. Two pieces adjacent to each other are switched with each other.
- AS2: adjacent switch 2. Same as above, but they are rotated differently.
- DR : diagonal rotation-only. Two pieces diagonally-adjacent to each other (they're on the same face but not adjacent) get rotated in place but not switched.
- DS1: diagonal switch 1. Two pieces diagonally-adjacent to each other are switched with each other.
- DS2: diagonal switch 2. Same as above, but they are rotated differently.
- OR : diagonal rotation-only. Two pieces diametrically-opposed to each other (they don't even share any face) get rotated in place but not switched.
- OS1: diagonal switch 1. Two pieces diametrically-opposed to each other are switched with each other.
- OS2: diagonal switch 2. Same as above, but they are rotated differently.
  
In the output, the first pair of brackets contains the pair of pieces that are affected.
A "t" means the piece is rotated clockwise. t' means counterclockwise.
An arrow between the two pieces means they are switched, not just rotated in place.
The pieces are coded from one corner to its diametric opposite.
Imagine the cube being balanced on the tip of one corner.
The bottom piece is 8. The top piece is 1. The three pieces adjacent to 1 are 2,3,4. The pieces adjacent to 8 are 6,7,8.
1 is opposite to 8, 2 is opposite to 7, 3 is opposite to 6, and 4 is opposite to 5.
Since we only look for one algorithm per "kind" of algorithm, we can just look for algorithms that modify two out of (1,2,7).
(1,2) is the adjacent pair, (1,7) is the diagonally-adjacent pair, and (2,7) is the diametrically-opposed pair.

The "inconvenience level" is some attempt to measure how much work you must do to perform the algorithm.
A front-face rotation costs more because I find it more awkward to rotate the front face from the way I hold the cube.
The output here shows the algorithm it found with the smallest inconvenience level.

## 4x4x4 top layer algorithms

In the file R4.jl, the function algs4 searches for 4x4x4 algorithms.
The intention is to find algorithms to solve the top layer, assuming the bottom 3 layers are already solved.
So each algorithm will affect only the top layer of the cube, and leave the bottom 3 intact.

Use it as follows from a Julia command line.
Most of the result is also shown here, from when I ran it on June 26th 2018.
This takes a while with 8 as an argument (any smaller argument yields nothing interesting),
so the method prints updates as it runs.
"halfAlgs" means a list of all the algorithms of (N/2) moves or less (not just top-layer algorithms),
and this list is then sorted so it can be used to generate the list of all the top-layer algorithms of N moves or less.

```
julia> algs4(8)
done halfAlgs, the number of them is 4667544.
And now the halfAlgs are sorted.
Done layeredAlgs! Their number is 21.

  Algorithm 1
---------------
 234 F CW
   1 R CCW
 234 F CCW
   1 U CW
 234 F CCW
   1 U CCW
 234 F CW
   1 R CW


  Algorithm 2
---------------
  23 F CW
   1 R CCW
 234 F CCW
   1 U CW
  23 F CCW
   1 U CCW
 234 F CW
   1 R CW

[...]

  Algorithm 21
---------------
 234 F CW
   1 U CW
 234 F CCW
 234 L CW
 234 F CW Twice
   1 R CCW
 234 F CW Twice
 234 L CCW
```

## Searching method

Here is a general description of how the program searches for Rubik's cube algorithms.

Every algorithm performs some permutation on the cube. You can think of it in terms of a permutation of squares (on a 3x3x3 cube there are 6 faces with 3x3 = 9 squares on each face for a total of 54 squares, so each algorithm is associated with a permutation of the numbers 1 through 54), or in terms of pieces (there are 3x3x3 - 1 = 26 pieces on a 3x3x3 cube) with the possibility to flip edge pieces and rotate corner pieces. In any case, we will think broadly in terms of permutations of numbers.

We are looking for algorithms that leave a certain set of pieces in place. For 4x4x4 last layer algorithms, all the pieces in the bottom 3 layers must stay in place, and for 2x2x2 algorithms only affecting 2 pieces the other 6 pieces must stay in place. In other words, we are looking for algorithms for which the permutation leaves a specified subset of the numbers intact.

Now say we want to find all the desired algorithms of N moves or less, and the number of choices for each move is M. For example, in a 3x3x3 cube each move is a rotation of a face, either clockwise, counterwise, or 180 degree, so that M = 6x3 = 18. A brute force solution would be to generate all the possible algorithms (all combinations of N moves or less, which makes a list of M^N algorithms) and then filter according to which algorithms keep the specified subset of numbers intact. But this is very inefficient, and searching for 4x4x4 last-layer algorithms this way has proven to take a very long time.

Another solution involves thinking about an algorithm as a combination of two half-algorithms. If a full algorithm keeps a certain subset of numbers intact, then it must be that its first half pushes these numbers to some other locations, and the second half pulls all these numbers back to their original locations. Now suppose you have two half-algorithms A and B, and each of them pushes the subset of numbers to the same locations. Then you can generate a full algorithm by saying "do A, then reverse B in time". So doing A will push the subset of numbers to some locations, and then reversing B in time will pull the pieces back to their original locations. The other numbers (that aren't included in the specified subset, so they represent the last layer for example) might be permuted among each other, which is what we want in a full algorithm.

So to find desired algorithms of 2N moves or less, we start by only generating all algorithms of N moves or less (the possible half-algorithms). Then we group the list of half-algorithms according to where they send the specified subset of numbers (in the program this involves sorting arrays according to only a subset of their elements). Then we know that in order to get a desired full algorithm by combining two half-algorithms as above, we must choose the two half-algorithms from the same group. So the program loops through the groups, and within each group it generates all possible pairs of two half-algorithms, and combines them to make a desired full algorithm.

This method has proven to be more efficient. We generate M^N half-algorithms, and sorting (mergesort) takes O(M^N * log(M^N)) = O(M^N * N * log(M)) which isn't too bad. Whereas the brute force method would take O(M^2N) to generate all possible algorithms.

The resulting list of desired full algorithms is filtered for some kinds of duplicates (sometimes one algorithm is just the mirror image of another for example), and the filtered list is then printed to the console.
