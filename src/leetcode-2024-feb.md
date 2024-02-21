##  2.17  [3007. 价值和小于等于 K 的最大数字](https://leetcode.cn/problems/maximum-number-that-sum-of-the-prices-is-less-than-or-equal-to-k/)

题解：https://leetcode.cn/problems/maximum-number-that-sum-of-the-prices-is-less-than-or-equal-to-k/

视频：https://www.bilibili.com/video/BV1zt4y1R7Tc/?vd_source=226da368954a7c68d6b7e4bbdc91b2cd

+ [数位DP](https://oi-wiki.org/dp/number/)
+ https://www.bilibili.com/video/BV1rS4y1s721/?spm_id_from=333.337.search-card.all.click&vd_source=226da368954a7c68d6b7e4bbdc91b2cd

如果用最朴素的想法去解题，我们需要知道下面三种操作

1. 操作1：求一个整数的价值 -> `O(1/x)`
2. 操作2：求从 1 到 num 所有整数的价值和 -> `O(num/x)`
3. 操作3：求最大的 num，使得 1 ... num 的价值和小于 k ->  `O(k^2/x)`

朴素算法的时间复杂度是 `O()`

又已知

- `1 <= k <= 10^15`
- `1 <= x <= 8`

又已知常见数据量下的时间复杂度：https://www.acwing.com/blog/content/32/

> 一般ACM或者笔试题的时间限制是1秒或2秒。
> 在这种情况下，C++代码中的操作次数控制在 10^7∼10^8 为最佳。

因此，上面的操作至少取一个对数；

所以可以想到用二分查找：

```rust
    pub fn find_maximum_number(k: i64, x: i32) -> i64 {
        let mut hi = 1 << x * (k.ilog2() as i32 + 1);
        let mut lo = 0;
        while lo <= hi {
            let mid = (hi + lo) / 2;
            let sum = Solution::sum_until(mid, x);
            if sum == k {
                return mid;
            } 
            if sum > k {
                lo = mid + 1;
            } else {
                hi = mid - 1;
            }
        }
        unreachable!()
    }
```

考虑sum_until 有较多重复计算，可使用数位 dp 减少重复。

注意优先级问题：

`dp_arr[i] = dp_arr[i - 1] * 2 - 1 + 1 << (*x* as usize * (i - 1))`

`*h* & !((2 << (i * *x*)) - 1)`

---

数位DP：**递归方程和从高到底按位枚举有关**

详见：https://algo.itcharge.cn/10.Dynamic-Programming/09.Digit-DP/01.Digit-DP/#_2-2-%E6%95%B0%E5%AD%97-1-%E7%9A%84%E4%B8%AA%E6%95%B0

基本框架：

```python
class Solution:
    def digitDP(self, n: int) -> int:
        # 将 n 转换为字符串 s
        s = str(n)
        
        @cache
        # pos: 第 pos 个数位
        # state: 之前选过的数字集合。
        # isLimit: 表示是否受到选择限制。如果为真，则第 pos 位填入数字最多为 s[pos]；如果为假，则最大可为 9。
        # isNum: 表示 pos 前面的数位是否填了数字。如果为真，则当前位不可跳过；如果为假，则当前位可跳过。
        def dfs(pos, state, isLimit, isNum):
            if pos == len(s):
                # isNum 为 True，则表示当前方案符合要求
                return int(isNum)
            
            ans = 0
            if not isNum:
                # 如果 isNumb 为 False，则可以跳过当前数位
                ans = dfs(pos + 1, state, False, False)
            
            # 如果前一位没有填写数字，则最小可选择数字为 0，否则最少为 1（不能含有前导 0）。
            minX = 0 if isNum else 1
            # 如果受到选择限制，则最大可选择数字为 s[pos]，否则最大可选择数字为 9。
            maxX = int(s[pos]) if isLimit else 9
            
            # 枚举可选择的数字
            for x in range(minX, maxX + 1): 
                # x 不在选择的数字集合中，即之前没有选择过 x
                if (state >> x) & 1 == 0:
                    ans += dfs(pos + 1, state | (1 << x), isLimit and x == maxX, True)
            return ans
    
        return dfs(0, 0, True, False)

```



---

此外均 sum_until 和 findMaximumNumber 实际上都有[简易的O(n)做法(找规律)](https://leetcode.cn/problems/maximum-number-that-sum-of-the-prices-is-less-than-or-equal-to-k/solutions/2603673/er-fen-da-an-shu-wei-dpwei-yun-suan-pyth-tkir/)
