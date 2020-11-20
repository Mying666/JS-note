#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
rm -rf ./docs/.vuepress/dist/
npm run build

git checkout gh-pages

# 删除原文件
rm -rf index.html assets/ 404.html

mv ./docs/.vuepress/dist/* ./

git add .
git commit -m 'deploy'
# git push -f git@github.com:Mying666/JS-note.git master
# git checkout master

cd -