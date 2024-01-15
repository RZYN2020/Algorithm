2023.10.5

---

在了解基本概念后，语言学习的最佳方法还是刷题。刷题并对比自己和他人的解答能教给你一些在代码编写的 "best practice" ，见多了这些 "best practice" 方才更有信心去做项目/读项目代码。

最近在学习 Haskell，就在 codewars 上找一些题目学习一下。

## Highest and Lowest

https://www.codewars.com/kata/554b4ac871d6813a03000035/haskell

慌忙 google 各种常用函数后得到如下答案（其中最大的问题是不知道如何给 expr 类型标注，所以把 read 封装成了 stringToInt）：

```haskell
stringToInt :: String -> Int
stringToInt = read

highAndLow :: String -> String
highAndLow input =
  let strs = words input in
   let nums = map stringToInt strs in
        show (maximum nums) ++ " " ++ show (minimum nums)
```

更好的解答1：

```haskell
highAndLow :: String -> String
highAndLow xs = show (maximum ns) ++ " " ++ show (minimum ns)
  where ns = (map read $ words xs) :: [Int]
```

1. where 和 let 似乎差不多... 但若是 预备工作太多 还是放在 where 里更好一些，因为 where 置后能更好凸显代码主体...

2. 对 expr 的类型标注用 `::` 就可以了，所以 上面的 `stringToInt` 可以替换为 `(read :: String -> Int)`

更好的解答2：

```haskell
highAndLow :: String -> String
highAndLow = unwords . map show . sequence [maximum,minimum] . map (read ::String->Int) . words
```

一行流...

[unwords](https://hackage.haskell.org/package/base-4.18.1.0/docs/Prelude.html#v:unwords): words 的 inverse

[sequence](https://hackage.haskell.org/package/base-4.17.2.0/docs/Data-Traversable.html#v:sequence): Evaluate each monadic action in the structure from left to right, and collect the results. [The `Traversable` class](https://hackage.haskell.org/package/base-4.17.2.0/docs/Data-Traversable.html#g:1) 的函数; class ([Functor](https://hackage.haskell.org/package/base-4.17.2.0/docs/Data-Functor.html#t:Functor) t, [Foldable](https://hackage.haskell.org/package/base-4.17.2.0/docs/Data-Foldable.html#t:Foldable) t) => Traversable t

+ https://blog.jakuba.net/2014-07-30-foldable-and-traversable/
+ https://downloads.haskell.org/~ghc/5.04.1/docs/html/base/index.html
+ https://wiki.haskell.org/Foldable_and_Traversable
+ !!! [Monad](https://hackage.haskell.org/package/base-4.7.0.0/docs/Control-Monad.html#t:Monad) ((->) r) https://hackage.haskell.org/package/base-4.14.1.0/docs/src/GHC.Base.html#line-979， 这个 Monad 可以理解为 Map?
+ 嗯...总之还是非常抽象...

解答3:

```haskell
highAndLow :: String -> String
highAndLow = unwords . map show . f . map read . words
    where f :: [Integer] -> [Integer]
          f xs = [maximum xs, minimum xs]
```

上面解答中烧脑的 `sequence [maximum,minimum]` 换成 `f`

解答4：

```haskell
highAndLow :: String -> String
highAndLow input = 
  let ns = map read $ words input :: [Int]
      mx = maximum ns
      mn = minimum ns
  in
    unwords $ map show [mx,mn]
```

很规整的一个解答

解答5：

```haskell
highAndLow :: String -> String
highAndLow = unwords . map show . highAndLow' . map read . words

highAndLow' :: [Int] -> [Int]
highAndLow' (n1:ns) = foldl (\[mx, mn] n -> [max mx n, min mn n]) [n1, n1] ns
```

稍微快点，但就没那么好看了

## Multiply

https://www.codewars.com/kata/50654ddff44f800200000004/haskell

```haskell
multiply :: Int -> Int -> Int
multiply a b = a * b
```

但感觉应该不是考点...

考点应该是如下解答中涉及的：

```haskell
multiply :: Int -> Int -> Int
multiply a b = fromJust $ do
  return $ a * b
```

## Tribonacci Sequence

https://www.codewars.com/kata/556deca17c58da83c00002db/haskell

```haskell
tribonacci :: (Num a) => (a, a, a) -> Int -> [a]
tribonacci (a, b, c) n =
  take n $
    map (\(x, _, _) -> x) ns
  where
    ns = iterate (\(x, y, z) -> (y, z, x + y + z)) (a, b, c)
```

emm...还是很麻烦的解答

解答1：

```haskell
tribonacci :: Num a => (a, a, a) -> Int -> [a]
tribonacci _ n | n < 1 = []
tribonacci (a, b, c) n = a : tribonacci (b, c, a+b+c) (n-1)
```

emmmm.... very very clever!!! 

在做本题的时候脑子里就没有产生过**递归**这个念头...被 wholemeal programming 毒害了么...

解答2：

```haskell
tribonacci :: Num a => (a, a, a) -> Int -> [a]
tribonacci (a, b, c) n = take n tribs
    where tribs = [a, b, c] ++ zipWith3 (\x y z -> x + y + z) tribs (tail tribs) (tail $ tail tribs)

-- 或类似的    
tribonacci :: Num a => (a, a, a) -> Int -> [a]
tribonacci (a, b, c) n = take n $ trib
    where trib = a : b : c : zipWith3 (\a b c -> a + b + c)
                                      (drop 0 trib)
                                      (drop 1 trib)
                                      (drop 2 trib)
```

人家也是 wholemeal programming，人家为什么这么优雅？！

噢，tribs 可以直接递归定义啊...

https://www.scs.stanford.edu/16wi-cs240h/slides/basics-slides.html#(8)

解答3：

```haskell
tribonacci :: Num a => (a, a, a) -> Int -> [a]
tribonacci sig n = take n $ unfoldr (\(a,b,c) -> Just (a,(b,c,a+b+c))) sig
```

还有 `unfoldr` 这么高级的函数吗...

https://hackage.haskell.org/package/deferred-folds-0.9.18.3/docs/DeferredFolds-Unfoldr.html

解答4：

```haskell
{-# LANGUAGE BangPatterns #-}

tribonacci :: Num a => (a, a, a) -> Int -> [a]
tribonacci (a, b, c) n = take n . go $ (a, b, c)
  where
    go (!x, !y, !z) = x : go (y, z, x + y + z)
```

BangPattern: https://ghc.gitlab.haskell.org/ghc/doc/users_guide/exts/strict.html ， 不 lazy 了

其余和解法一类似

## 其它

https://en.wikibooks.org/wiki/Haskell/Understanding_monads

发现一门非常好的课程...决定先看这个了 https://www.scs.stanford.edu/16wi-cs240h/sched/
