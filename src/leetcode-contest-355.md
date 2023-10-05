

2023.8.23

---

[contest-355](https://leetcode.cn/contest/weekly-contest-355/)

本科喊了三年的要学算法，前半年又为了找实习喊了好几个月的要刷题，可终究是没有刷起来。主要原因是懒，次要原因是还是在思想上还是轻视了。。

不过最近越发意识到计算机科学的灵魂还是关于计算的。在各个软件系统中反复遇到一些似曾相识的模式(比如屡见不鲜的不动点算法)之后，我越发感到需要一层更高的抽象来统一这些关于计算的模式了。但是计算又好像往往难以抽象，每个算法本身就较为复杂且算法之间的共同性又较少，支配算法题目的好像只是些模糊的“思想”，如“分治”，“动态规划”之类的。这些思想又以意想不到的方式结合在一个题目中，让人无法通过一种“算法”去解决所有算法问题。相比于人为限定的逻辑推理规则，这种灵活多变的“思想”似乎才是更为普遍的。对于思想的学习那就只能靠“悟”了，而“悟”不能光靠看，必须要思考，动手后才能体会，因此做题也是必不可少了。

成功说服自己后，终于做了一次leetcode周赛，结果自然是惨不忍睹，只过了两道简单。。希望以后坚持下去能有进步吧。

我感觉Python最适合用来做算法题，可以让人只关注纯粹的计算而很少担心语言本身的问题。不过因为想着顺便学习下Rust，就先用Rust做几次题。

## [2789. 合并后数组中的最大元素](https://leetcode.cn/problems/largest-element-in-an-array-after-merge-operations/)

```rust
impl Solution {
    pub fn max_array_value(nums: Vec<i32>) -> i64 {
        nums.into_iter().rfold(0i64, |acc, num| {
            if acc >= num as i64 {
                acc + num as i64
            } else {
                num as i64
            }
        })
    }
}
```

直觉：观察 操作 ，容易得出若数组中有相邻的三个元素 abc，若 a < b < c 则一定有  a < b + c，所以对于数组的递增区间可以从右到左进行操作将区间内所有数加起来；操作后不影响该区间右侧的递减区间，因此可以从右向左扫描合并所有递增区间(on fly)。

## [2788. 按分隔符拆分字符串](https://leetcode.cn/problems/split-strings-by-separator/)

```rust
impl Solution {
    pub fn split_words_by_separator(words: Vec<String>, separator: char) -> Vec<String> {
        words
            .into_iter()
            .flat_map(|word| {
                word.split(separator)
                    .filter(|w| !w.is_empty())
                    .map(str::to_string)
                    .collect::<Vec<String>>()
            })
            .collect()
    }
}
```

直觉：分割即可。用flat_map方便些。

## [2791. 树中可以形成回文的路径数](https://leetcode.cn/problems/count-paths-that-can-form-a-palindrome-in-a-tree/)

```rust
use std::{collections::{HashMap, btree_map::Entry}, process::id};
impl Solution {
    #[inline(always)]
    fn to_bits(c: char) -> Option<u32> {
        let offset = c as u32 - 'a' as u32;
        if offset < 26 {
            return Some(1 << offset);
        }
        None
    }

    pub fn count_palindrome_paths(parent: Vec<i32>, s: String) -> i64 {
        let mut pal_cnt: i64 = 0;
        let mut xors: HashMap<u32, i64> = HashMap::new();
        let chars: Vec<char> = s.chars().collect();
        let mut graph: HashMap<i32, Vec<i32>> = HashMap::new();
        for (idx, ele) in parent.iter().enumerate() {
            graph.entry(*ele).or_insert(vec![]).push(idx as i32);
        }
        
        xors.insert(0, 1);
        let mut stack: Vec<(i32, u32)> = vec![(0, 0)];
        while let Some((cur, p_xor)) = stack.pop() {
            if let Some(v) = graph.get(&cur) {
                for nxt in v {
                    let xor = p_xor ^ Self::to_bits(*chars.get(*nxt as usize).unwrap()).unwrap();
                    pal_cnt += (0..26)
                        .into_iter()
                        .map(|i| *xors.get(&((1 << i) ^ xor)).unwrap_or(&0))
                        .sum::<i64>();
                    pal_cnt += xors.get(&xor).unwrap_or(&0);
                    *xors.entry(xor).or_insert(0) += 1;
                    stack.push((*nxt, xor));
                }
            }
        }
        return pal_cnt as i64;
    }
}
```

直觉：

1. 需要枚举所有可能点对然后判断。

2. 已知路径如何判断是否回文？-> 奇偶性即可判断

3. 已知一对点如何知道路径？-> 从lca出发的两条路径合并(判断回文恰好也不需要考虑方向，所以可以分别走然后合并)

4. 如何表示路径信息？-> 如果用HashMap需要多次copy，考虑到只需要保存奇偶信息且字母表有限，用bitset即可

   1. 使用bitset之后发现路径的合并恰好可以用bitset之间的亦或表示

5. 如何枚举所有的点对？点对之间是否有依赖关系可以利用？

   1. 递归遍历，针对每个节点进行操作

      > 思路类似于[点分治](https://oi-wiki.org/graph/tree-divide/)

   2. 的确是有依赖关系（父节点可利用子节点已知的路径信息），但难以利用（因为需要子节点保存所有路径信息，这开销又不小）。此外一个节点作为lca时两个子树互相匹配时间复杂度过大(n^2)

6. 这里卡壳了，然后看题解：

   1. 如何利用依赖关系减少计算？考虑 a ^ b ^ a = b 因此路径 a -> b -> c ^ a -> b -> d = c ->b -> d。因为路径间的相互抵消。我们不需要单独存储每个点到它某个祖先节点的路径，任何两个点之间的路径都可以有两个点到根节点的路径异或得到！
   2. 枚举点对时可以利用两数之和的思路。（不要被字母表吓到，只要它有限，就是O(1)！

7. 所以最后就能以`O(n)`的时间复杂度解决这道题

## [2790. 长度递增组的最大数目](https://leetcode.cn/problems/maximum-number-of-groups-with-increasing-length/)

```rust
impl Solution {
    pub fn max_increasing_groups(usage_limits: Vec<i32>) -> i32 {
        let mut ord_limits = usage_limits.into_iter().map(|x| x as i64).collect::<Vec<i64>>();
        ord_limits.sort();
        ord_limits.into_iter()
            .fold((0, 0), |(cur, rem), num| {
                if rem + num >= cur + 1 {
                    (cur + 1, rem + num - cur - 1)
                } else {
                    (cur, rem + num)
                }
            })
            .0 as i32
    }
}
```

直觉：

1. 先排个序，试着构造一下
2. 从多到少尝试逼近题目要求，多的可以消去
3. 发现思路不太对，又考虑如何把一个递增序列打乱，若有了打乱算法能否逆向还原
4. 思索无果，看题解：
   1. 从少到多尝试逼近题目要求，多的可以补到后面（震惊

## 反思

### 思考方式

做了做题发现自己的思维还是很单纯的。。。

做题就两个思路：

1. 枚举并分别判断，然后在此基础上看能不能消除依赖关系（枚举也可以是一种构造，不过显然构造难度太大
2. 构造，正向不行就反向（构造也可以算一种枚举，枚举所有可能结构并判断是否满足构造条件->但是有的题显然搜索空间太大，只能构造

一个技巧：

1. 特化，不用的信息就别管了，降低点常数时间。

后面两个难题都是这样套，但却没有套成。

尝试泛化一下几个题：

给某个结构的定义，求满足某个性质的结构的集合。不同点在于结构的定义方式以及性质（好像没啥用

思路好像就是这样，但为什么做不出来呢？

关键就在于如何消除“依赖关系”以及如何“构造”是靠直觉的。。。但是我经过的训练较少没能养成这样的直觉。

拿 2791 来看，其依赖关系在于 任意两点之间的 路径 依赖于 它们到 根节点 的路径，且这个依赖关系是由异或运算的性质保证的。但是我没想到异或的这个性质，没有这个性质的提示自然也就想不到真正的依赖关系了。而之前做的动态规划又给了我一种一定是“子节点依赖父节点”的错觉，所以就一直往这方面考虑了。

拿 2790  来看，如果我在考虑直觉2时稍微反一下就可以把构造想出来了，但是却最后陷入了错误的思路里去。

两道题因为感觉做不出陷入死胡同来而放弃了，但如果后面能在做题的同时记录自己的思考方式，也许能避免这种陷入死胡同的感觉。

### 算法

查 2791 相关资料时发现了许多算法：

如上面提到的点分治，以及[求lca的算法](https://www.cnblogs.com/lsdsjy/p/4071041.html)。忽然想起来之前写编译器做类型推导求最小父类时也涉及求lca，但当时好像用了一个时间复杂度非常高的暴力做法。。

另外做这份笔记时本来打算既写“直觉”，也写证明的，但是感觉写算法的证明比写算法难多了。。。对于这种有测试用例的题目还是相信直觉了。。。

## Rust

rust的许多函数式特性和集合非常有用。

JonGjengset的youtube频道有关于它们的很好的介绍

+ [collection](https://www.youtube.com/watch?v=EF3Z4jdD1EQ&ab_channel=JonGjengset)
+ [iter](https://www.youtube.com/watch?v=yozQ9C69pNs&ab_channel=JonGjengset)

发现两个有关rust的有趣的项目：

+ [frunk crate](https://beachape.com/frunk/frunk/index.html)：rust函数式编程支持 
+ [cranelift](https://cranelift.dev/)：rust似乎计划未来用这个替代llvm作为后端(这样就完全自举了！) 

文章:

+ [Rust的类型系统是图灵完备的！](https://sdleffler.github.io/RustTypeSystemTuringComplete/)
+ [ebpf不是图灵完备的！](https://blog.trailofbits.com/2023/01/19/ebpf-verifier-harness/#:~:text=The%20key%20to%20eBPF%20safety,design%2C%20not%20Turing%2Dcomplete.)

书籍：

+ [effective rust](https://www.lurklurk.org/effective-rust/cover.html)

课程:

+ [15-816 Linear Logic](https://www.cs.cmu.edu/~fp/courses/98-linear/handouts.html)  by [Frank Pfenning](http://www.cs.cmu.edu/~fp/) 
