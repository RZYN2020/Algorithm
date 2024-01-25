## 1.14 [822. 翻转卡片游戏](https://leetcode.cn/problems/card-flipping-game/)

```rust
use std::collections::HashSet;
impl Solution {
    pub fn flipgame(fronts: Vec<i32>, backs: Vec<i32>) -> i32 {
        let mut wants = HashSet::new();
        let mut n_wants = HashSet::new();
        for i in 0..fronts.len() {
            wants.insert(fronts[i]);
            wants.insert(backs[i]);
            if fronts[i] == backs[i] {
                n_wants.insert(fronts[i]);
            }
        }
        wants = wants.difference(&n_wants).copied().collect();

        wants.into_iter().min().unwrap_or(0)
    }
}
```

复健活动...

## 1.20 [1938. 查询最大基因差](https://leetcode.cn/problems/maximum-genetic-difference-query/description/)

此题一见就想到了下面这种暴力解法，如果 queries 长 n，parents 长 m，则时间复杂度 `O(n logm)`

```rust
impl Solution {
    pub fn max_genetic_difference(parents: Vec<i32>, queries: Vec<Vec<i32>>) -> Vec<i32> {
        let mut ans = Vec::<i32>::new();
        for query in queries {
            if let [mut n, v] = query[..] {
                let mut max_v = v ^ n;
                while n != -1 {
                    n = parents[n as usize];
                    max_v = max_v.max(n ^ v);
                }
                ans.push(max_v);
            } else {
                unreachable!()
            }
        }
        ans
    }
}
```

问题在于测试数据中 m 可能太大，因此 TLE

考虑到 n 不可省略，问题在于如何减小 log m 这个因子。考虑比较的过程在于从 leaf 到 root 计算 log m 次异或并取最大值，转而思考 求若干次异或操作的最大值有无简便方法。

异或为二进制按位比较，相同为 0，不同为 1。而比较大小为二进制按位比较先出现 1 的大。那么一个数 a 若干数异或操作的最大值就可以通过按位判断哪个数最先出现与 a 不同的位。这种按序列不断递进的感觉就让人想到了 Trie 树。

考虑使用 Trie 树，结果如下。因为每个数位数有限，复杂度 `O(n+m)`

·

```rust
const MAX_BIT: usize = 18;

#[derive(Debug)]
struct Trie {
    left:  Option<Box<Trie>>,  // 0
    right: Option<Box<Trie>>, // 1
    cnt: usize
}

impl Trie {

    pub fn new() -> Trie {
        Trie {
            left: None,
            right: None,
            cnt: 0,
        }
    }

    pub fn insert(trie: &mut Trie, n: i32) {
        let mut cur = trie;
        for i in (0..=MAX_BIT).rev()  {
            cur.cnt += 1;
            let bit = n & (1 << i);
            if bit != 0 {
                cur = cur.right.get_or_insert(Box::new(Trie::new()))
            } else {
                cur = cur.left.get_or_insert(Box::new(Trie::new()))
            }
        }
        cur.cnt += 1;
    }

    pub fn remove(trie: &mut Trie, n: i32) {
        let mut cur = trie;
        for i in (0..=MAX_BIT).rev()  {
            cur.cnt -= 1;
            let bit = n & (1 << i);
            if bit != 0 {
                cur = cur.right.get_or_insert(Box::new(Trie::new()))
            } else {
                cur = cur.left.get_or_insert(Box::new(Trie::new()))
            }
        }
        cur.cnt -= 1;
    }


    pub fn max(trie: &Trie, v: i32) -> i32 {
        let mut cur = trie;
        let mut p = 0;
        for i in (0..=MAX_BIT).rev()  {
            let bit = v & (1 << i);
            // try to select different bit:
            if bit != 0 {
                if cur.left.is_some() && cur.left.as_ref().unwrap().cnt != 0 {
                    cur = cur.left.as_ref().unwrap();
                } else {
                    p += 1 << i;
                    cur = cur.right.as_ref().unwrap();
                }
                
            } else {
                if cur.right.is_some() && cur.right.as_ref().unwrap().cnt != 0{
                    p += 1 << i;
                    cur = cur.right.as_ref().unwrap();
                } else {
                    cur = cur.left.as_ref().unwrap();
                }
            }
        }
        p ^ v
    }

}


impl Solution {

    pub fn max_genetic_difference(parents: Vec<i32>, queries: Vec<Vec<i32>>) -> Vec<i32> {
        // assign queries -> O(n)
        let mut node_queries = vec![Vec::<(usize, i32)>::new(); parents.len()];
        let query_len = queries.len();

        for (i, query) in queries.into_iter().enumerate() {
            if let [n, v] = query[..] {
                node_queries[n as usize].push((i, v))
            } else {
                unreachable!() 
            }
        }

        // build graph -> O(m)
        let mut graph = vec![Vec::<i32>::new(); parents.len()];
        let mut root = 0;
        for (n, p) in parents.into_iter().enumerate() {
            if p == -1 {
                root = n;
            } else {
                graph[p as usize].push(n as i32);
            }
        }
        
        // dfs -> O(m log MAX_BIT)，log MAX_BIT 为在 Trie 中插入/删除每个数的时间
        let mut ans = vec![0; query_len];
        let mut stack = vec![(root, false)];
        let mut trie = Trie::new();
        
        while let Some((n, visited)) = stack.pop() {
            if visited {
                Trie::remove(&mut trie, n as i32);
                continue;
            }
            stack.push((n, true));
            Trie::insert(&mut trie, n as i32);
            for (i, v) in node_queries[n].iter() {
                ans[*i] = Trie::max(&trie, *v);
            }
            for child in graph[n].iter() {
                stack.push((*child as usize, false))
            }
        }


        ans
    }
}
```



## 1.21 [构造最长非递减子数组](https://leetcode.cn/problems/longest-non-decreasing-subarray-from-two-arrays/)

第一眼没有考虑清楚，没有认识到对每一个位置的决策都会对后续决策产生影响，有了下面错误答案。

```rust
impl Solution {
    pub fn max_non_decreasing_length(nums1: Vec<i32>, nums2: Vec<i32>) -> i32 {
        let l = nums1.len();

        let mut res = 0;
        let mut maxl = 0;
        let mut cur = 0;
        for i in 0..l {
            let min = nums1[i].min(nums2[i]);
            let max = nums1[i].max(nums2[i]);
            if min >= cur {
                cur = min;
                maxl += 1;
            } else if max >= cur {
                cur = min;
                maxl += 1;
            } else {
                res = res.max(maxl);
                maxl = 1;
                cur = min;
            }
        }
        res.max(maxl)
    }
}
```

考虑到影响后，意识到每个位置选数组 A 或选数组 B 都要考虑，考虑可以划分子问题，找到依赖关系。又因为是否能选位置 n 上的某个数取决于位置 n-1 上的数，得出如下答案：

```rust
    // 如果把「子数组」改成「子序列」呢？ -> 转化为求一个数组的最长非递减子序列 -> 存在 O(nlog⁡n) 解法
    // https://leetcode.cn/problems/longest-increasing-subsequence/
    // https://www.bilibili.com/video/BV1XW4y1f7Wv/?spm_id_from=333.999.0.0&vd_source=ebce05e0e6ac0774e7cf8844bf20f437
    pub fn max_non_decreasing_length(nums1: Vec<i32>, nums2: Vec<i32>) -> i32 {

        let (mut last_min, mut last_max) = (0, 0);

        let mut lmin_l = 0;
        let mut lmax_l = 0;

        let mut max_l = 0;


        for i in 0..nums1.len() {
            let min = nums1[i].min(nums2[i]);
            let max = nums1[i].max(nums2[i]);

            let lmin_l_ = if min >= last_max {
                lmax_l + 1
            } else if min >= last_min {
                lmin_l + 1
            } else {
                1
            };
    
            lmax_l = if max >= last_max {
                lmax_l + 1
            } else if max >= last_min {
                lmin_l + 1
            } else {
                1
            };
            lmin_l = lmin_l_;
            

            last_min = min;
            last_max = max;
            max_l = max_l.max(lmax_l);
        }

        max_l
    }
```

## 1.22 [2304. 网格中的最小路径代价](https://leetcode.cn/problems/minimum-path-cost-in-a-grid/)

一眼动态规划，但注意：

1. MAX_COST 最大值
2. 下标写对

```rust
    pub fn min_path_cost(grid: Vec<Vec<i32>>, move_cost: Vec<Vec<i32>>) -> i32 {
        const MAX_COST: i32 = std::i32::MAX;

        let m = grid.len();
        let n = grid[0].len();
        let mut min_path = vec![vec![MAX_COST; n]; m];

        for i in 0..n {
            min_path[0][i] = grid[0][i];
        }

        // O(mn^2)
        for i in 1..m {
            for j in 0..n {
                for k in 0..n {
                    let parent_val = grid[i - 1][j];
                    let total_cost = grid[i][k] + move_cost[parent_val as usize][k];
                    min_path[i][k] = min_path[i][k].min(min_path[i - 1][j] + total_cost);
                }
            }
        }
        
        *min_path[m - 1].iter().min().unwrap()
    }
```

## 1.25 [2498. 青蛙过河 II](https://leetcode.cn/problems/frog-jump-ii/description/)

构造题，这 tm 谁能想到...

证明：间隔跳所得结果为所有间隔的最大值。假设存在非间隔跳最优解，则必拆分最大间隔，最大间隔拆分后反程间隔必大于原最大间隔，矛盾。故间隔跳为最优解。

```rust
impl Solution {
    pub fn max_jump(stones: Vec<i32>) -> i32 {
        let mut max_jmp = stones[1] - stones[0];
        for i in 2..stones.len() {
            max_jmp = max_jmp.max(stones[i] - stones[i - 2]);
        }
        max_jmp
    }
}
```

此外，检查可否在最大长度不超过`m`的情况下往返，二分查找 `m` 即可。（这种思路其实更有启发性）
