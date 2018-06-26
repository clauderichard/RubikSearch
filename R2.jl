
include("Sorting.jl")

module R2

  importall Base
  importall Sorting
  
  export R2Object,println,
         CubeChange,*,==,isless,isless5,compare,compare5,
         indices2,indices5,
         Algorithm,mkAlgorithmFromAtomicMove,oneMoveAlgorithms,
         getAllHalfAlgs,getGroupedHalfAlgs!,categorizedWholeAlgs8,
         algs8, algsX
  
  ################################################################################
  
  abstract R2Object
  function println( o :: R2Object )
    print( o )
    println()
  end
  function print{T<:R2Object}( arr :: Array{T} )
    for i = 1:length(arr)
      print(arr[i])
      if i < length(arr)
        print(' ')
        #println()
      end
    end
  end
  function println{T<:R2Object}( arr :: Array{T} )
    for o = arr
      println(o)
    end
  end
  
  compare( x :: Int64, y :: Int64 ) = x<y ? -1 : x>y ? 1 : 0
  
  ################################################################################
  # Globals indices
  
  indices5 = [3,4,5,6,7]
  indices2 = [1,2]
  function setIndices2( i :: Int64, j :: Int64 )
    indices2 = [i,j]
    a = 1
    for b = 1:7
      if b!=i && b!=j
        indices5[a] = b
        a += 1
      end
    end
  end
  
  function compare5( x :: Array{Int64}, y :: Array{Int64} )
    for a = 1:5
      c = compare( x[indices5[a]], y[indices5[a]] )
      if c!=0
        return c
      end
    end
    return 0
  end
  
  ################################################################################
  # CubeChange
  ################################################################################
  
  type CubeChange <: R2Object
    pos :: Array{Int64} # permutation of 7 corners.
    rot :: Array{Int64} # rotation (after the permutation) of each corner.
  end
  
  # We will only print two-piece-affecting algorithms,
  # so this function relies on that assumption.
  function print( x :: CubeChange )
    print( "(" )
    
    for i = 1:7
      if x.rot[i] != 0
        print( " ", i )
        print( x.rot[i]==1 ? "t" : "t'")
      end
    end
    
    done = falses(7)
    for i = 1:7
      if !done[i] && x.pos[i] != i
        print( " ", i )
        done[i] = true
        j = x.pos[i]
        while j!=i
          print("->", j)
          done[j] = true
          j = x.pos[j]
        end
      else
        done[i] = true
      end
    end
    print( " )" )
  end
  
  idCubeChange = CubeChange( [1,2,3,4,5,6,7], [0,0,0,0,0,0,0] )
  centerCubeChange = CubeChange( [4,2,1,7,5,6,3], [0,0,0,0,0,0,0] )
  leftCubeChange = CubeChange( [2,6,3,1,5,4,7], [1,2,0,2,0,1,0] )
  rightCubeChange = CubeChange( [3,1,5,4,2,6,7], [2,1,1,0,2,0,0] )
  
  ==( x :: CubeChange, y :: CubeChange ) = x.pos == y.pos && x.rot == y.rot
  
  function compare( x :: CubeChange, y :: CubeChange )
    c = compare( x.pos, y.pos )
    if c==0
      return compare( x.rot, y.rot )
    end
    return c
  end
  function compare5( x :: CubeChange, y :: CubeChange )
    c = compare5( x.pos, y.pos )
    if c==0
      return compare5( permute!(copy(x.rot),x.pos), permute!(copy(y.rot),y.pos) )
    end
    return c
  end
  
  isless(x :: CubeChange, y :: CubeChange) = compare(x,y) < 0
  isless5(x :: CubeChange, y :: CubeChange) = compare5(x,y) < 0
  
  equal5(x :: CubeChange, y :: CubeChange) = compare(x,y) == 0
  
  # Do y, then do x
  function *( x :: CubeChange, y :: CubeChange)
    newPos = permute!( copy(y.pos), x.pos )
    newRot = ipermute!( copy(x.rot), y.pos )
    for i = 1:7
      newRot[i] = ( newRot[i] + y.rot[i] ) % 3
    end
    CubeChange( newPos, newRot )
  end
  
  # reverse a cube change
  function reverse( x :: CubeChange )
    newPos = invperm(x.pos)
    newRot = permute!( copy(x.rot), x.pos )
    for i = 1:7
      newRot[i] = (3 - newRot[i]) % 3
    end
    CubeChange( newPos, newRot )
  end
  
  # Whether B * A^-1 switches pieces or not, and whether it rotates or not.
  # 0 = do nothing
  # 1 = twist only
  # 2 = switch only
  # 3 = switch and a twist
  #function categorizePair( x :: CubeChange, y :: CubeChange )
  #  #p = x.pos == y.pos
  #  #r = x.rot == y.rot
  #  #return p ? (r ? 0 : 1) : r ? 2 : 3
  #end
  function categorize8( x :: CubeChange )
    p = true
    for i = 1:7
      if x.pos[i] != i
        p = false
        break
      end
    end
    r = true
    for i = 1:7
      if x.rot[i] > 0
        r = false
        break
      end
    end
    return (p ? 0 : 2) + (r ? 0 : 1)
  end
  function categorize15( x :: CubeChange )
    p = true
    for i = 1:7
      if x.pos[i] != i
        p = false
        break
      end
    end
    r = 0
    for i = 1:7
      if x.rot[i] > 0
        r = x.rot[i]
        break
      end
    end
    return (p ? 0 : 3) + r
  end
  
  ################################################################################
  # More globals about atomic moves
  
  atomicMovesValid = [1,2,3,4,5,6,7,8,9]
  atomicMoveInconveniences = [2,3,2,4,6,4,2,3,2]
  
  numAtomicMoves = length(atomicMovesValid)
  atomicMoveNames = [ "R ", "R2", "R'", "F ", "F2", "F'", "U ", "U2", "U'" ]
  atomicCubeChanges = [ centerCubeChange, centerCubeChange*centerCubeChange, reverse(centerCubeChange),
                        leftCubeChange, leftCubeChange*leftCubeChange, reverse(leftCubeChange),
                        rightCubeChange, rightCubeChange*rightCubeChange, reverse(rightCubeChange) ]
  function moveInconvenience( m :: Int64 )
    return atomicMoveInconveniences[m]
    return (m==5) ? 20 : (m==4 || m==6) ? 14 : (m%3==2) ? 3 : 2
  #  return (m%3==2) ? 3 : 2
  end
  function reverseMoveCode( m :: Int64 )
    # 1 switches with 3 and vice versa.
    # 4 switches with 6 and vice versa.
    # 7 switches with 9 and vice versa.
    return m%3==0 ? m-2 : m%3==1 ? m+2 : m
  end
  
  ################################################################################
  # Algorithm
  ################################################################################
  
  type Algorithm <: R2Object
    moveList :: Array{Int64} # from beginning to end
    cubeChange :: CubeChange
  end
  function print( x :: Algorithm )
    for m = x.moveList
      print( atomicMoveNames[m], " ")
    end
    print( " " )
    print( x.cubeChange )
    print( " ( ", length(x.moveList), " moves )" )
    println( " ( inconvenience level ", inconvenience(x), " )")
  end
  
  idAlgorithm = Algorithm( [], idCubeChange )
  
  ==( x :: Algorithm, y :: Algorithm ) = x.cubeChange == y.cubeChange
  
  function inconvenience( x :: Algorithm )
    s = 0
    for m = x.moveList
      s += moveInconvenience(m)
    end
    return s
  end
  compare( x :: Algorithm, y :: Algorithm ) = compare( x.cubeChange, y.cubeChange )
  compare5( x :: Algorithm, y :: Algorithm ) = compare5( x.cubeChange, y.cubeChange )
  compareInconvenience( x :: Algorithm, y :: Algorithm ) = compare( inconvenience(x), inconvenience(y) )
  
  isless( x :: Algorithm, y :: Algorithm ) = compare( x, y ) < 0
  isless5( x :: Algorithm, y :: Algorithm ) = compare5( x, y ) < 0
  equal5(x :: Algorithm, y :: Algorithm) = compare( x, y ) == 0
  
  mkAlgorithmFromAtomicMove( atomicMove :: Int64 ) = Algorithm( [atomicMove], atomicCubeChanges[atomicMove] )
  
  # Do y then do x
  *( x :: Algorithm, y :: Algorithm ) = Algorithm( vcat( y.moveList, x.moveList ), x.cubeChange * y.cubeChange )
  
  function reverse( x :: Algorithm )
    newMoveList = copy(x.moveList)
    for i = 1:length(x.moveList)
      newMoveList[length(x.moveList)+1-i] = reverseMoveCode( x.moveList[i] )
    end
    return Algorithm( newMoveList, reverse(x.cubeChange) )
  end
  
  categorize8( x :: Algorithm ) = categorize8( x.cubeChange )
  categorize15( x :: Algorithm ) = categorize15( x.cubeChange )
  #categorizePair( x :: Algorithm, y :: Algorithm ) = categorizePair( x.cubeChange, y.cubeChange )
  # B * A^-1
  function combinePair( x :: Algorithm, y :: Algorithm )
    return x * reverse(y)
  end
  
  ################################################################################
  # Generate 8 algorithms
  
  # Get a list of all algorithms possible by combining a half-alg from xs with a half-alg from ys.
  # Whole algorithms will be x*y so "do y then do x".
  function *( xs :: Array{Algorithm}, ys :: Array{Algorithm} )
    xys = Array{Algorithm}( length(xs) * length(ys) )
    i = 1
    for x = xs
      for y = ys
        xys[i] = x*y
        i += 1
      end
    end
    xys = vcat(xs,xys)
    mergeSort!(xys)
    return removeDuplicatesBy!( compareInconvenience, xys )
  end
  
  function incrementHalfAlgs( xs :: Array{Algorithm} )
    ret = Array{Algorithm}( length(xs) * numAtomicMoves )
    i = 1
    for x = xs
      for y = oneMoveAlgorithms
        ret[i] = x*y
        i += 1
      end
    end
    return ret
  end
  
  # Get a list of all algorithms possible of n moves or less. Except duplicates.
  #function getAllHalfAlgs( n :: Int64 )
  #  i = 1
  #  ret = vcat( [idAlgorithm], oneMoveAlgorithms )
  #  retLimited = oneMoveAlgorithms
  #  for i = 2:n
  #    retLimited = incrementHalfAlgs( retLimited )
  #    ret = vcat( ret, retLimited )
  #  end
  #  return ret
  #end
  
  # Get a list of all algorithms possible of n moves or less. Except duplicates.
  function getAllHalfAlgs( n :: Int64 )
    if n==1
      return vcat( [idAlgorithm], oneMoveAlgorithms )
    end
    if n%2==0
      hn = getAllHalfAlgs( div(n,2) )
      return hn*hn
    else
      hn = getAllHalfAlgs( div(n,2) )
      hn1 = hn * oneMoveAlgorithms
      return hn * hn1
    end
    #n1 = getAllHalfAlgs( n-1 )
    #return n1 * oneMoveAlgorithms
  end
  
  function getGroupedHalfAlgs!( halfAlgs :: Array{Algorithm}, pair1 :: Int64, pair2 :: Int64 )
    setIndices2( pair1, pair2 )
    hag = groupBy!( isless5, halfAlgs )
    filteredHag = filter( g -> length(g)>1, hag )
  end
  
  function algorithmShorter( x :: Algorithm, y :: Algorithm )
    #s = length(x.moveList) < length(y.moveList)
    #if s
    #  return s
    #end
    return inconvenience(x) < inconvenience(y)
  end
  
  function getCategorizedWholeAlgs( halfAlgs :: Array{Algorithm},
                                    numCategories :: Int64, categorizer :: Function,
                                    pair1 :: Int64, pair2 :: Int64 )
    ret = Array{Algorithm}( numCategories )
    gs = getGroupedHalfAlgs!( halfAlgs, pair1, pair2 )
    
    for g = gs
      m = length(g)
      for i = 1:(length(g)-1)
        a = g[i]
        for j = (i+1):length(g)
          b = g[j]
          ab = combinePair(a,b)
          category = categorizer( ab )
          if category > 0
            if !isdefined( ret, category ) || algorithmShorter( ab, ret[category] )
              ret[category] = ab
            end
          end
        end
      end
    end
    return ret
  end
  
  function categorizedWholeAlgs( halfN :: Int64, numCategories :: Int64, categorizer :: Function )
    ret = Array{Algorithm}(3,3)
    
    halfAlgs = getAllHalfAlgs( halfN )
    
    for pairCode = 1:3
      pair1 = pairCode == 3 ? 2 : 1
      pair2 = pairCode == 1 ? 2 : 7
      algs3 = getCategorizedWholeAlgs( halfAlgs, 3, categorize8, pair1, pair2 )
      
      # pick shortest from each category.
      for i = 1:3
        if isdefined( algs3, i )
          ret[pairCode,i] = algs3[i]
        end
      end
    end
    return ret
  end
  
  function algsX_helper( halfN :: Int64, numCategories :: Int64, categorizer :: Function )
    halfAlgs = getAllHalfAlgs( halfN )
    for pair1 = 1:6
      for pair2 = (pair1+1):7
        wholeAlgs = getCategorizedWholeAlgs( halfAlgs, numCategories, categorizer, pair1, pair2 )
        for i = 1:length(wholeAlgs)
          printAlgIfDefined( wholeAlgs, i )
        end
      end
    end
  end
  function algsX( halfN :: Int64, categorizerCode :: Int64 )
    numCategories = categorizerCode == 1 ? 3 : 5
    categorizer = categorizerCode == 1 ? categorize8 : categorize15
    algsX_helper( halfN, numCategories, categorizer )
  end
  
  function printAlgIfDefined( algsArr :: Array{Algorithm,1}, i :: Int64 )
    if isdefined( algsArr, i )
      print( algsArr[i] )
    else
      println( "NOT FOUND" )
    end
  end
  function printAlgIfDefined( algsArr :: Array{Algorithm,2}, i :: Int64, j :: Int64 )
    if isdefined( algsArr, i, j )
      print( algsArr[i,j] )
    else
      println( "NOT FOUND" )
    end
  end
  
  function printCategorizedAlg( name, algsArr :: Array{Algorithm,2}, i :: Int64, j :: Int64 )
    print(name, ":  ")
    if isdefined( algsArr, i, j )
      print( algsArr[i,j] )
    else
      println( "NOT FOUND" )
    end
  end
  
  # halfN = 6 finds all the switching ones...
  function algs8( halfN :: Int64 )
    algs33 = categorizedWholeAlgs( halfN, 3, categorize8 )
    
    printCategorizedAlg( "AR ", algs33, 1, 1 )
    printCategorizedAlg( "AS1", algs33, 1, 3 )
    printCategorizedAlg( "AS2", algs33, 1, 2 )
    
    printCategorizedAlg( "DR ", algs33, 2, 1 )
    printCategorizedAlg( "DS1", algs33, 2, 2 )
    printCategorizedAlg( "DS2", algs33, 2, 3 )
    
    printCategorizedAlg( "OR ", algs33, 3, 1 )
    printCategorizedAlg( "OS1", algs33, 3, 2 )
    printCategorizedAlg( "OS2", algs33, 3, 3 )
    
    #algs33
    
  end
  
  ################################################################################
  # More globals about algorithms
  
  oneMoveAlgorithms = Array{Algorithm}( numAtomicMoves )
  for i = 1:numAtomicMoves
    j = atomicMovesValid[i]
    oneMoveAlgorithms[i] = Algorithm( [j], atomicCubeChanges[j] )
  end
  
  ################################################################################
  
end
