# 获取当前日期和时间
$now = Get-Date
$dateTime = $now.ToString("yyyy-MM-dd HH:mm")

# 设置提交信息
$commitMessage = "commit  [$dateTime]"

# 执行 mkdocs build
mkdocs build

# 执行 git add .
git add .

# 执行 git commit -m"$commitMessage"
git commit -m $commitMessage

# 执行 git push
git push py