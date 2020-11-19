#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 删除原文件
rm -rf docs/index.html docs/assets/ docs/404.html

# 生成静态文件
npm run build

mv ./docs/.vuepress/dist/* ./docs/

git add -A
git commit -m 'deploy'
git push -f https://github.com/Mying666/JS-note.git master

cd -