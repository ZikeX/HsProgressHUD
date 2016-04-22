#!/bin/sh

echo "submit"
git add -A && git commit -m "Release $1"

echo "add tag $1"
git tag '$1

echo "push tags"
git push --tags

echo "push origin"
git push origin master

echo "pod trunk push"
//提交给spec
pod trunk push --verbose --allow-warnings
