module Sorting

  importall Base

  export mergeSortPartialBy!, mergeSortBy!, mergeSortPartial!, mergeSort!, 
         mergeSortPartialBy, mergeSortBy, mergeSortPartial, mergeSort,
         mergeSortByFunc!, mergeSortByFunc,
         removeDuplicates!, union!,
         removeDuplicates, union
  
  ################################################################################
  
  function mergePartialBy!{T}( islessf, arr :: Array{T}, a :: Int, m :: Int, b :: Int )
    aa = Array{T}(b-a+1)
    i = a
    j = m+1
    k = 1
    while i <= m && j <= b
      if islessf(arr[i], arr[j])
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

  function mergeSortPartialBy!{T}( islessf, arr :: Array{T}, a :: Int, b :: Int )
    if a == b
      return arr
    end
    if b-a == 1
      if islessf(arr[b], arr[a])
        c = arr[a]
        arr[a] = arr[b]
        arr[b] = c
      end
      return arr
    end
    m = div(b-a+1,2) + a - 1
    mergeSortPartialBy!(islessf, arr, a, m)
    mergeSortPartialBy!(islessf, arr, m+1, b)
    return mergePartialBy!(islessf, arr, a, m, b)
  end

  function mergeSortBy!{T}( islessf, arr :: Array{T} )
    if length(arr) == 1
      return arr
    end
    return mergeSortPartialBy!( islessf, arr, Int(1), length(arr) )
  end
  
  function mergeSortByFunc!{T}( f, arr :: Array{T} )
    return mergeSortBy!( (x,y) -> f(x) < f(y), arr )
  end
  
  ################################################################################
  
  # assumes the array is sorted already
  function removeDuplicates!{T}( arr :: Array{T} )
    n = length(arr)
    if n==0
      return arr
    end
    j = 0
    for i = 1:(n-1)
      if arr[i] != arr[i+1]
        j += 1
        arr[j] = arr[i]
      end
    end
    j += 1
    arr[j] = arr[n]
    # j is number of unique values
    resize!(arr,j)
    return arr
  end
  
  function union!{T}( arr :: Array{T} )
    return removeDuplicates!( mergeSort!( arr ) )
  end
  
  ################################################################################
  
  # assumes the array is sorted already
  function removeDuplicates{T}( arr :: Array{T} )
    return removeDuplicates!( copy(arr) )
  end
  
  function union{T}( arr :: Array{T} )
    return union!( copy(arr) )
  end
  
  ################################################################################
  
  function mergePartial!{T}( arr :: Array{T}, a :: Int, m :: Int, b :: Int )
    return mergePartialBy!( isless, arr, a, m, b )
  end

  function mergeSortPartial!{T}( arr :: Array{T}, a :: Int, b :: Int )
    return mergeSortPartialBy!( isless, arr, a, b )
  end

  function mergeSort!{T}( arr :: Array{T} )
    return mergeSortBy!( isless, arr )
  end

  ################################################################################
  
  function mergePartialBy{T}( islessf, arr :: Array{T}, a :: Int, m :: Int, b :: Int )
    return mergePartialBy!( islessf, copy(arr), a, m, b )
  end

  function mergeSortPartialBy{T}( islessf, arr :: Array{T}, a :: Int, b :: Int )
    return mergeSortPartialBy!( islessf, copy(arr), a, b )
  end

  function mergeSortBy{T}( islessf, arr :: Array{T} )
    return mergeSortBy!( islessf, copy(arr) )
  end

  function mergeSortByFunc{T}( f, arr :: Array{T} )
    return mergeSortByFunc!( f, copy(arr) )
  end
  
  ################################################################################
  
  function mergePartial{T}( arr :: Array{T}, a :: Int, m :: Int, b :: Int )
    return mergePartial!( copy(arr), a, m, b )
  end
  function mergeSortPartial{T}( arr :: Array{T}, a :: Int, b :: Int )
    return mergeSortPartial!( copy(arr), a, b )
  end
  function mergeSort{T}( arr :: Array{T} )
    return mergeSort!( copy(arr) )
  end

  ################################################################################
  
end