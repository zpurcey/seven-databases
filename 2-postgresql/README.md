# Week 1 Study Notes

## GIT Notes

### Clone a repo

```
git clone https://github.com/zpurcey/seven-databases.git
git remote add upstream https://github.com/codingbynumbers/seven-databases.git
# Crap just realised my upstream is my account not codingbynumbers.  How do I change my upstream remote?
git fetch upstream
git merge upstream/master
#Will merging (just cause I fixed the upstream remote) risk my VM getting reverted and lose db changes to date?
```

### Commit a new file

```
cd seven-databases
touch README.md
git add README.md
git commit -m 'commit comments'
git push origin master
```

### Create a Branch?

```
git branch mybranch
# Creates a new branch called "mybranch"

git checkout mybranch
# Makes "mybranch" the active branch

git checkout -b mybranch
# Creates a new branch called "mybranch" and makes it the active branch

git checkout master
# Makes "master" the active branch

git merge mybranch
# Merges the commits from "mybranch" into "master"

git branch -d mybranch
# Deletes the "mybranch" branch

git branch mybranch
# Creates a new branch called "mybranch"

```