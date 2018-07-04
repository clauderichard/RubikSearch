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
