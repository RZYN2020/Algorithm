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