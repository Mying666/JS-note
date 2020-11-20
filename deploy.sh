#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

git checkout gh-pages

# 删除原文件
rm -rf index.html assets/ 404.html

# 生成静态文件
# npm run build

mv ./docs/.vuepress/dist/* ./

git add -A
git commit -m 'deploy'
# git push -f git@github.com:Mying666/JS-note.git master
git checkout master

cd -