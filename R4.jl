
import Base: ==, *, /, \, isless, show, invperm

################################################################################

function arrayEquals{T}( x :: Array{T}, y :: Array{T} )
  n = length(x)
  if length(y) != n
    return false
  end
  for i = 1:n
    if x[i] != y[i]
      return false
    end
  end
  return true
end

function arrayCompare{T}( x :: Array{T}, y :: Array{T} )
  n = length(x)
  if length(y) != n
    return false
  end
  for i = 1:n
    if x[i] < y[i]
      return -1
    elseif x[i] > y[i]
      return 1
    end
  end
  return 0
end

################################################################################

# arr[i] == j  means what was in position j went to position i
type Perm
  arr :: Array{Int8}
end

function one( Perm, n :: Int )
  return Perm(1:n)
end

function ==( x :: Perm, y :: Perm )
  return arrayEquals( x.arr, y.arr )
end

function equalUpTo( x :: Perm, y :: Perm, n :: Int )
  for i = 1:n
    if x.arr[i] != y.arr[i]
      return false
    end
  end
  return true
end

function constUpTo( x :: Perm, n :: Int)
  return arrayEquals( 1:n, x[1:n] )
end

function numDifferent(x :: Perm)
  ret = 0
  for i = 1:length(x.arr)
    if x.arr[i] != i
      ret += 1
    end
  end
  return ret
end

# Do x, then do y
function *( x :: Perm, y :: Perm)
  a = copy( x.arr )
  permute!( a, y.arr )
  return Perm( a )
end
# Reverse x, then do y
function \( x :: Perm, y :: Perm )
  a = invperm( x.arr )
  permute!( a, y.arr )
  return Perm( a )
end
function square( x :: Perm )
  return x * x
end

function invperm( p :: Perm )
  return Perm( invperm(p.arr) )
end

function isless{T}(arr1 :: Array{T}, arr2 :: Array{T})
  for i = 1:length(arr1)
    if arr1[i] < arr2[i]
      return true
    end
    if arr1[i] > arr2[i]
      return false
    end
  end
  return false
end

function isless(x :: Perm, y :: Perm)
  for i = 1:length(x.arr)
    if x.arr[i] < y.arr[i]
      return true
    elseif x.arr[i] > y.arr[i]
      return false
    end
  end
  return false
end

################################################################################

function permFromCycle(n :: Int, arr :: Array{Int})
  p = one(Perm)
  q = copy(arr)
  mergeSort!(q)
  for i = 1:length(arr)
    p.arr[q[i]] = arr[i]
  end
  return p
end

################################################################################

function isodd( p :: Perm )
  n = length(p.arr)
  seen = Array{Bool}(n)
  ret = false
  for i = 1:n
    if seen[i]
      continue
    end
    if p.arr[i] == i
      seen[i] = true
      continue
    end
    #Start a cycle
    cycLengthOdd = true
    cycat = i
    while !seen[cycat]
      seen[cycat] = true
      cycat = p.arr[cycat]
      cycLengthOdd = !cycLengthOdd
    end
    if cycLengthOdd
      ret = !ret
    end
  end
  return ret
end
function iseven( p :: Perm )
  return !isodd(p)
end

################################################################################

function mergePartial!{T}(arr :: Array{T}, a :: Int, m :: Int, b :: Int)
  aa = Array{T}(b-a+1)
  i = a
  j = m+1
  k = 1
  while i <= m && j <= b
    if isless(arr[i], arr[j])
      aa[k] = arr[i]
      i += 1
    else
      aa[k] = arr[j]
      j += 1
    end
    k += 1
  end
  while i <= m
    aa[k] = arr[i]
    i += 1
    k += 1
  end
  while j <= b
    aa[k] = arr[j]
    j += 1
    k += 1
  end
  for x = a:b
    arr[x] = aa[x-a+1]
  end
  return arr
end

function mergeSortPartial!{T}(arr :: Array{T}, a :: Int, b :: Int)
  if a == b
    return arr
  end
  if b-a == 1
    if ! isless(arr[a], arr[b])
      c = arr[a]
      arr[a] = arr[b]
      arr[b] = c
    end
    return arr
  end
  m = div(b-a+1,2) + a - 1
  mergeSortPartial!(arr, a, m)
  mergeSortPartial!(arr, m+1, b)
  mergePartial!(arr, a, m, b)
end

function mergeSort!{T}(arr :: Array{T})
  if length(arr) == 1
    return arr
  end
  return mergeSortPartial!(arr, Int(1), length(arr))
end

################################################################################
# CenterPerm assumes the centers are matched up already,
# and describes how they will be shuffled around by a permutation,
# while keeping in mind the pieces' interchangeability.
# Each 4-tuple in the array (there are 6 of them) should be sorted ascendingly
# since we don't care about the ordering.

numCenterPiecesPerFace = 4
numCenterPieces = 24
type CenterPerm
  arr :: Array{Int8}
end

function mkNullCenterPerm()
  return CenterPerm(collect(1:numCenterPieces))
end

function ==( a :: CenterPerm, b :: CenterPerm )
  return arrayEquals( a, b )
end

function *( a :: CenterPerm, b :: CenterPerm )
  c = CenterPerm(copy(a))
  permute!(c,b)
  for i = 1:4:24
    mergeSortPartial!(c,i,i+3)
  end
end

################################################################################

type Position
  du :: Int8
  fb :: Int8
  lr :: Int8
  kind :: Int8 # 1 for side, 2 for center, 3 for corner
  code :: Int8 # its number in the permutation arrays
end

function allPositions()
  ret = Array{Position}(4,4,4)
  sidecode = 1
  centercode = 1
  cornercode = 1
  for du = 1:4
    duinner = (du==2 || du==3)
    for fb = 1:4
      fbinner = (fb==2 || fb==3)
      for lr = 1:4
        lrinner = (lr==2 || lr==3)
        if (lrinner && duinner && fbinner)
          continue
        end
        if (lrinner || duinner || fbinner)
          if ((lrinner && duinner) || (lrinner && fbinner) || (duinner && fbinner))
            # center
            ret[du,fb,lr] = Position(du,fb,lr,2,centercode)
            centercode += 1
          else
            # side
            ret[du,fb,lr] = Position(du,fb,lr,1,sidecode)
            sidecode += 1
          end
        else
          # corner
          ret[du,fb,lr] = Position(du,fb,lr,3,cornercode)
          cornercode += 1
        end
      end
    end
  end
  return ret
end

################################################################################

type Rotation
  axis :: Int8 # 1 for Bottom, 2 for Front, 3 for Right.
  layers :: Array{Int8} # 1 for outer layer, 2 for first inner layer, etc.
  direction :: Int8 # 1 for CW, 2 for 180, 3 for CCW.
  sidePerm :: Perm
  centerPerm :: Perm
  cornerPerm :: Perm
end

function ==(x :: Rotation, y :: Rotation)
  return x.axis == y.axis &&
    arrayEquals(x.layers,y.layers) &&
    x.direction == y.direction
end

function invrot( r :: Rotation )
  return Rotation(
    r.axis,
    r.layers,
    4 - r.direction,
    invperm(r.sidePerm),
    invperm(r.centerPerm),
    invperm(r.cornerPerm))
end

# rotate one point around an axis.
function rotatePointCW( du :: Int8, fb :: Int8, lr :: Int8, axis :: Int8 )
  if axis==1
    return ( du, lr, Int8(5)-fb )
  elseif axis==2
    return ( Int8(5)-lr, fb, du )
  else # if axis==3
    return ( fb, Int8(5)-du, lr )
  end
end
function rotatePoint( du :: Int8, fb :: Int8, lr :: Int8, axis :: Int8, dir :: Int8 )
  (a,b,c) = (du,fb,lr)
  for i = 1:dir
    (a,b,c) = rotatePointCW(a,b,c,axis)
  end
  return (a,b,c)
end

function mkRotation( allPos :: Array{Position}, axis :: Int8, layer :: Int8, dir :: Int8 )
  numPieces = (layer==1 || layer==4) ? 16 : 12
  sidePermArr = collect(1:24)
  centerPermArr = collect(1:24)
  cornerPermArr = collect(1:8)
  
  poss = Array{Position}(numPieces)
  k = 1
  for i = 1:4
    for j = 1:4
      if (i==1 || i==4 || j==1 || j==4 || layer==1 || layer==4)
        if axis==1
          poss[k] = allPos[layer,i,j]
        elseif axis==2
          poss[k] = allPos[i,layer,j]
        else
          poss[k] = allPos[i,j,layer]
        end
        k += 1
      end
    end
  end
  
  for i = 1:numPieces
    (newdu,newfb,newlr) = rotatePoint( poss[i].du, poss[i].fb, poss[i].lr, axis, dir )
    newpos = allPos[newdu,newfb,newlr]
    if newpos.kind==1
      sidePermArr[newpos.code] = poss[i].code
    elseif newpos.kind==2
      centerPermArr[newpos.code] = poss[i].code
    else
      cornerPermArr[newpos.code] = poss[i].code
    end
  end
  
  return Rotation(axis, [layer], dir, Perm(sidePermArr), Perm(centerPermArr), Perm(cornerPermArr))
end

function combineRotations( a :: Rotation, b :: Rotation )
  if a.axis != b.axis
    return -1
  elseif a.direction != b.direction
    return -2
  elseif length(a.layers) != 1 && length(b.layers) != 1
    return -3
  end
  layers = Array{Int8}(0)
  append!(layers, a.layers)
  append!(layers, b.layers)
  return Rotation(a.axis, layers, a.direction, a.sidePerm*b.sidePerm, a.centerPerm*b.centerPerm, a.cornerPerm*b.cornerPerm)
end

function rotationSequenceMakesSense( a :: Rotation, b :: Rotation )
  return a.axis != b.axis
  if a.axis == b.axis
    if a.direction==b.direction
      if length(a.layers)==1 && length(b.layers)==1
        if a.layers[1]*b.layers[1] == 2 # 1&2
          return false
        elseif a.layers[1]*b.layers[1] == 12 # 3&4
          return false
        end
      end
    end
    if arrayEquals(a.layers, b.layers)
      return false
    elseif arrayEquals(a.layers, [Int8(1),Int8(2)]) && arrayEquals(b.layers, [Int8(3),Int8(4)])
      return false
    elseif arrayEquals(b.layers, [Int8(1),Int8(2)]) && arrayEquals(a.layers, [Int8(3),Int8(4)])
      return false
    elseif a.direction == b.direction
      # doing 1 CW then 2 CW is stupid.
      if arrayEquals(a.layers, [Int8(1)]) && arrayEquals(a.layers, [Int8(2)])
        return false
      elseif arrayEquals(a.layers, [Int8(2)]) && arrayEquals(a.layers, [Int8(1)])
        return false
      elseif arrayEquals(a.layers, [Int8(4)]) && arrayEquals(a.layers, [Int8(3)])
        return false
      elseif arrayEquals(a.layers, [Int8(3)]) && arrayEquals(a.layers, [Int8(4)])
        return false
      elseif length(a.layers) + length(b.layers) >= 3 && ((a.layers[1] <= 2 && b.layers[1] >= 3) || (b.layers[1] <= 2 && a.layers[1] >= 3))
        return false
      end
    end
    if a.direction == (4 - b.direction)
      # doing 1 CW then 12 CCW is stupid for example.
      if length(a.layers)==1
        for i = 1:length(b.layers)
          if b.layers[i] == a.layers[1]
            return false
          end
        end
      end
      if length(b.layers)==1
        for i = 1:length(a.layers)
          if a.layers[i] == b.layers[1]
            return false
          end
        end
      end
    end
  end
  return true
end

function rotationTripleMakesSense( a :: Rotation, b :: Rotation, c :: Rotation )
  return a.axis != b.axis && b.axis != c.axis
  if a.axis == b.axis && a.axis == c.axis
    return false
  end
  return true
end

function allRotations()

  allPos = allPositions()
  
  ret = Array{Rotation}(3*7*3)
  i = 1
  for ax = 1:3
    for dir = 1:3
      for lay = 2:4
        ret[i] = mkRotation( allPos, Int8(ax), Int8(lay), Int8(dir) )
        i += 1
      end
      ret[i] = combineRotations( ret[i-3], ret[i-2] )
      i += 1
      ret[i] = combineRotations( ret[i-4], ret[i-2] )
      i += 1
      ret[i] = combineRotations( ret[i-4], ret[i-3] )
      i += 1
      ret[i] = combineRotations( ret[i-6], ret[i-1] )
      i += 1
    end
  end
  
  return ret
  
end

################################################################################

type Algorithm
  rotations :: Array{Rotation}
  sidePerm :: Perm
  centerPerm :: Perm
  cornerPerm :: Perm
  #sortingCode :: BigInt
end

function mkAlgorithm(rots :: Array{Rotation})
  s = rots[1].sidePerm
  ce = rots[1].centerPerm
  co = rots[1].cornerPerm
  for i = 2:length(rots)
    s = s * rots[i].sidePerm
    ce = ce * rots[i].centerPerm
    co = co * rots[i].cornerPerm
  end
  return Algorithm(rots, s, ce, co)
end

function sortCodifyAlgorithm!( a :: Algorithm )
  factor = BigInt(1)
  index = 32
  ret = BigInt(0)
  for i in 24:-1:17
    ret += factor * (a.sidePerm.arr[i]-1)
    #index += 1
    factor *= index
  end
  for i in 8:-1:1
    ret += factor * (a.cornerPerm.arr[i]-1)
    #index += 1
    factor *= index
  end
  for i in 16:-1:1
    ret += factor * (a.sidePerm.arr[i]-1)
    #index += 1
    factor *= index
  end
  #a.sortingCode = ret
end
function sortCodifyAlgorithms!( algs :: Array{Algorithm} )
  for i = 1:length(algs)
    sortCodifyAlgorithm!(algs[i])
  end
end

function oneRotationAlgorithm( rot :: Rotation )
  return mkAlgorithm( [rot] )
end

function isless(a1 :: Algorithm, a2 :: Algorithm)
  #return isless(a1.sidePerm, a2.sidePerm)
  
  #return a1.sortingCode < a2.sortingCode
  
  # now sort by first 16 side piece destinations, then by corners, then by last 8 side pieces
  c = arrayCompare(a1.sidePerm.arr[1:16], a2.sidePerm.arr[1:16])
  if c < 0
    return true
  elseif c > 0
    return false
  end
  c = arrayCompare(a1.cornerPerm.arr, a2.cornerPerm.arr)
  if c < 0
    return true
  elseif c > 0
    return false
  end
  c = arrayCompare(a1.sidePerm.arr[17:24], a2.sidePerm.arr[17:24])
  return c < 0
end

function invalg( a :: Algorithm )
  n = length(a.rotations)
  rots = Array{Rotation}( n )
  for i = 1:n
    rots[n+1-i] = invrot( a.rotations[i] )
  end
  return Algorithm(
    rots,
    invperm(a.sidePerm),
    invperm(a.centerPerm),
    invperm(a.cornerPerm) )
end

function *(a1 :: Algorithm, a2 :: Algorithm)
  rots = Array{Rotation}( length(a1.rotations) + length(a2.rotations) )
  for i = 1:length(a1.rotations)
    rots[i] = a1.rotations[i]
  end
  for i = 1:length(a2.rotations)
    rots[i + length(a1.rotations)] = a2.rotations[i]
  end
  return Algorithm(
    rots,
    a1.sidePerm * a2.sidePerm,
    a1.centerPerm * a2.centerPerm,
    a1.cornerPerm * a2.cornerPerm )
end

function isNotSandwichedAlgorithm( a :: Algorithm )
  if length(a.rotations)>2
    ri = a.rotations[1]
    rf = a.rotations[length(a.rotations)]
    if ri.axis==1 && rf.axis==1 && ri.direction == 4-rf.direction
      rilayers = Array{Int8}(0)
      if ri.layers[length(ri.layers)] == Int8(4)
        append!(rilayers,ri.layers[1:(length(ri.layers)-1)])
      else
        append!(rilayers,ri.layers)
      end
      rflayers = Array{Int8}(0)
      if rf.layers[length(rf.layers)] == Int8(4)
        append!(rflayers,rf.layers[1:(length(rf.layers)-1)])
      else
        append!(rflayers,rf.layers)
      end
      if arrayEquals(rilayers, rflayers)
        return false
      end
    end
  end
  return true
end

################################################################################

function show(r :: Rotation)
  layers = r.layers
  axis = r.axis
  dir = r.direction
  if (r.layers[1]>2)
    layers = Array{Int8}(length(r.layers))
    for i = 1:length(r.layers)
      layers[i] = 5 - r.layers[length(layers)+1-i]
    end
    axis = -axis
    dir = 4-dir
  end
  
  for i = (length(layers)+1):4
    print(" ")
  end
  for i = 1:length(layers)
    print(layers[i])
  end
  
  if axis==1
    print(" D ")
  elseif axis==2
    print(" F ")
  elseif axis==3
    print(" L ")
  elseif axis==-1
    print(" U ")
  elseif axis==-2
    print(" B ")
  else # if axis==-3
    print(" R ")
  end
  if dir==1
    println("CW")
  elseif dir==2
    println("CW Twice")
  else
    println("CCW")
  end
end
function show(alg :: Algorithm)
  for i = 1:length(alg.rotations)
    show(alg.rotations[i])
  end
  println()
end
function show(algs :: Array{Algorithm})
  println()
  for i = 1:length(algs)
    println("  Algorithm ", i)
    println("---------------")
    show(algs[i])
    println()
  end
end

################################################################################

function allAlgs(moves :: Array{Rotation}, numMoves)
  if numMoves==1
    retalgs = Array{Algorithm}(length(moves))
    for i = 1:length(moves)
      retalgs[i] = oneRotationAlgorithm(moves[i])
    end
    return retalgs
  end
  subsequents = allAlgs(moves, numMoves-1)
  ret = Array{Algorithm}( 0 )
  for m = 1:length(moves)
    oneMoveAlg = oneRotationAlgorithm( moves[m] )
    for s = 1:length(subsequents)
      if rotationSequenceMakesSense( oneMoveAlg.rotations[1], subsequents[s].rotations[1] )
        if length(subsequents[s].rotations)<2 || rotationTripleMakesSense( oneMoveAlg.rotations[1], subsequents[s].rotations[1], subsequents[s].rotations[2] )
          append!(ret, [oneMoveAlg * subsequents[s]])
        end
      end
    end
  end
  i = 1
  for m = (length(moves)*length(subsequents) + 1):length(ret)
    ret[m] = subsequents[i]
    i += 1
  end
  return ret
end

topRot = mkRotation( allPositions(), Int8(1), Int8(4), Int8(1) )

function appendOneWaySelfCross(fun, isok, firstisok, src, i, j, dest)
  temparr = Array{typeof(fun(src[i],src[j]))}( (j-i+1)*(j-i+1) )
  #println("temparr from i=",i," to j=",j)
  m = 1
  for k = i:j
    a = src[k]
    if firstisok(a)
      for l = (k+1):j
        #if l==k
        #  continue
        #end
        c = fun( a, src[l] )
        if isok(c)
          temparr[m] = c
          m += 1
        end
      end
    end
  end
  #filter!( isok, temparr[1:(m-1)] )
  append!( dest, temparr[1:(m-1)] )
end
function funForAppendOneWaySelfCross(a :: Algorithm, b :: Algorithm)
  return invalg(a) * b
end

function algsCounteractEachOther( a :: Algorithm, b :: Algorithm, numConstSides, numConstCorners)
  # return true iff a.sortingCode and b.sortingCode have the same first 20 digits
  #if abs(a.sortingCode - b.sortingCode) >= BigInt(32)^12
  #  return false
  #end
  return equalUpTo(a.sidePerm, b.sidePerm, numConstSides) && equalUpTo(a.cornerPerm, b.cornerPerm, numConstCorners)
end

function isrelevantalg( a :: Algorithm )
  n = length(a.rotations)
  lastRot = a.rotations[n]
  # if last rotation is the top
  if lastRot.axis == 1 && arrayEquals(lastRot.layers, [Int8(4)])
    return false
  elseif !isNotSandwichedAlgorithm(a)
    return false
  elseif isstupidalg(topRot, a)
    return false
  elseif isredundantalg(a)
    return false
  # filter out algs that mess up the centers
  elseif !keepsCenters(a)
    return false
  # filter out algs that mess up the corners
  elseif !keepsBottomCorners(a)
    return false
  end
  
  return true
end

function isrelevantstartofalg( halfAlg :: Algorithm )

  n = length(halfAlg.rotations)
  firstrot = halfAlg.rotations[n]

  # filter out algs that start with R or L
  # (because you can do the same by starting with F)
  if firstrot.axis == 3
    return false
  # filter out algs that start with the back layer
  # (because you can do the same by starting with F)
  elseif firstrot.axis == 2 && firstrot.layers[1] >= 3
    return false
  # filter out algs that start with CCW
  # (because you can mirror them)
  elseif firstrot.direction == 1
    return false
  # filter out algs that start with rotating the top
  elseif firstrot.axis == 1 && arrayEquals(firstrot.layers, [Int8(4)])
    return false
  end
  
  return true
end

function bucketFunc( a :: Algorithm, level )
  if level > 16
    return a.cornerPerm.arr[level-16]
  else
    return a.sidePerm.arr[level]
  end
end

function bucketSortPartial!(arr :: Array{Algorithm}, i, j, numBuckets, maxLevel, level, mergeSortAfter)
  temparr = Array{Algorithm}(numBuckets, length(arr))
  temparrSizes = Array{Int32}(numBuckets)
  for k = 1:numBuckets
    temparrSizes[k] = 0
  end
  for k = i:j
    b = bucketFunc(arr[k], level)
    temparrSizes[b] += 1
    temparr[ b, temparrSizes[b] ] = arr[k]
  end
  k = i
  for b = 1:numBuckets
    for l = 1:temparrSizes[b]
      arr[k] = temparr[b,l]
      k += 1
    end
  end
  if level<maxLevel
    k = i
    for b = 1:numBuckets
      bucketSortPartial!(arr, k, k + temparrSizes[b]-1, numBuckets, maxLevel, level+1, mergeSortAfter)
      k += temparrSizes[b]
    end
  elseif mergeSortAfter
    k = i
    for b = 1:numBuckets
      if temparrSizes[b]>1
        mergeSortPartial!(arr, k, k + temparrSizes[b]-1)
      end
      k += temparrSizes[b]
    end
  end
end

function bucketSort!( arr :: Array{Algorithm}, numBuckets, maxLevel, mergeSortAfter)
  bucketSortPartial!( arr, 1, length(arr), numBuckets, maxLevel, 1, mergeSortAfter)
end

# algorithms for a given layer.
function layeredAlgs(moves :: Array{Rotation}, numMovesHalved, layer :: Int)
  # numConstSides is number is side pieces (from bottom up) that should remain in place
  numConstSides = layer==2 ? 8 : layer==3 ? 12 : 16
  numConstCorners = 4
  permSize = length( moves[1].sidePerm.arr )
  halfAlgs = allAlgs(moves, numMovesHalved)
  println("done halfAlgs, the number of them is ", length(halfAlgs), ".")
  
  #sortCodifyAlgorithms!(halfAlgs)
  #println("And now they're sort-codified.")
  
  numConst = numConstSides+numConstCorners
  numBuckets = 24
  bucketSort!( halfAlgs, numBuckets, 1, true )
  println("And now the halfAlgs are sorted.")
  
  nHalf = length(halfAlgs)
  
  #println(sum(halfAlgsGroupedSizes))
  #println(nHalf)
  
  ret = Array{Algorithm}(0)
  n = nHalf
  i = 1
  while i < n
    if algsCounteractEachOther(halfAlgs[i], halfAlgs[i+1], numConstSides, numConstCorners)
      j = i+1
      while j < n && algsCounteractEachOther(halfAlgs[i], halfAlgs[j+1], numConstSides, numConstCorners)
        j += 1
      end
      #println("Found a group! bucket=",bucket," i=",i," j=",j)
      appendOneWaySelfCross(funForAppendOneWaySelfCross, isrelevantalg, isrelevantstartofalg, halfAlgs, i, j, ret)
      i = j+1
    else
      i += 1
    end
  end
  
  return ret
end

################################################################################

function isstupidalg(rot :: Rotation, a :: Algorithm)
  ap = a.sidePerm
  p = rot.sidePerm
  for i = 1:4
    if ap==p
      return true
    end
    p = p * rot.sidePerm
  end
  return false
end

function algContainsNoStupidity( a :: Algorithm )
  for i = 1:(length(a.rotations)-1)
    if !rotationSequenceMakesSense(a.rotations[i], a.rotations[i+1])
      return false
    elseif i <= (length(a.rotations)-2)
      if !rotationTripleMakesSense(a.rotations[i], a.rotations[i+1], a.rotations[i+2])
        return false
      end
    end
  end
  return true
end

function theyRotateSameLayer( r1 :: Rotation, r2 :: Rotation )
  if r1.axis != r2.axis
    return false
  elseif !arrayEquals(r1.layers,r2.layers)
    return false
  end
  return true
end

function isredundantalg( alg :: Algorithm )
  for i = 1:(length(alg.rotations)-1)
    if theyRotateSameLayer(alg.rotations[i], alg.rotations[i+1])
      return true
    end
  end
  return false
end

function issideodd( r :: Rotation )
  if r.direction==2
    return false
  end
  ret = false
  for i = 1:length(r.layers)
    if r.layers[i]==2 || r.layers[i]==3
      ret = !ret
    end
  end
  return ret
end
function iscornerodd( r :: Rotation )
  if r.direction==2
    return false
  end
  ret = false
  for i = 1:length(r.layers)
    if r.layers[i]==1 || r.layers[i]==4
      ret = !ret
    end
  end
  return ret
end
function issideodd( a :: Algorithm )
  ret = false
  for i = 1:length(a.rotations)
    if issideodd(a.rotations[i])
      ret = !ret
    end
  end
  return ret
end
function iscornerodd( a :: Algorithm )
  ret = false
  for i = 1:length(a.rotations)
    if iscornerodd(a.rotations[i])
      ret = !ret
    end
  end
  return ret
end

################################################################################

function keepsCenters( alg :: Algorithm )
  csi = [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6]
  csf = copy(csi)
  permute!(csf, alg.centerPerm.arr)
  return arrayEquals(csi,csf)
end

function keepsBottomCorners( alg :: Algorithm )
  csi = Array{Int8}(8)
  csf = Array{Int8}(8)
  for i = 1:4
    csi[i] = Int8(i)
    csf[i] = Int8(i)
    csi[i + 4] = Int8(5)
    csf[i + 4] = Int8(5)
  end
  permute!(csf, alg.cornerPerm.arr)
  return arrayEquals(csi,csf)
end

################################################################################

function getAlgs4(numMoves)

  allPos = allPositions()
  allRot = allRotations()
  topRot = mkRotation( allPos, Int8(1), Int8(4), Int8(1) )
  
  x = layeredAlgs(allRot, div(numMoves,2), 4)
  println("Done layeredAlgs! Their number is ", length(x), ".")
  
  filter!(algContainsNoStupidity, x)
  
  return x
  
end

function algs4( numMoves )
  a4 = getAlgs4( numMoves )
  show(a4)
end

################################################################################

# one move may have several different rotations on the same axis,
# so one layer can be CW the other CCW in one move for example.
type AxisMove
  axis :: Int8
  rotations :: Array{Tuple{Int8,Int8}}
  sidePerm :: Perm
  centerPerm :: Perm
  cornerPerm :: Perm
end

################################################################################
