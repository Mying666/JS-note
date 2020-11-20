#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
npm run build

# 切换分支
git checkout gh-pages

# 删除原文件
rm -rf index.html assets/ 404.html

mv ./docs/.vuepress/dist/* ./

git add .
git commit -m 'deploy'
git push -f origin gh-pages
git checkout master
rm -rf ./docs/.vuepress/dist

cd -