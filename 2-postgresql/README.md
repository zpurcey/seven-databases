# Week 1 Study Notes

## GIT Notes

### Clone a repo

```
git clone https://github.com/zpurcey/seven-databases.git
git remote add upstream https://github.com/codingbynumbers/seven-databases.git
# Crap just realised my upstream is my account not codingbynumbers.  How do I change my upstream remote?
git fetch upstream
git merge upstream/master
```
**Question** Will merging (just cause I fixed the upstream remote) risk my VM getting reverted and lose db changes to date?

I branched Day 3 although not sure if this is where it would merge given it says upstream/**master**.  Seemed to work:

```
Andrew-Purcells-MacBook-Pro-2:2-postgresql apurcell$ git merge upstream/master
Merge made by the 'recursive' strategy.
 2-postgresql/provision.sh                   |  26 ++-
 3-riak/.kerl/archives/MD5                   | 265 +++++++++++++++++++++++++++
 3-riak/.kerl/archives/otp_src_R15B01.tar.gz | Bin 0 -> 75592537 bytes
 3-riak/Vagrantfile                          |  97 ++++++++++
 3-riak/kerl                                 | 902 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3-riak/provision.sh                         |  33 ++++
 3-riak/readme.md                            |  11 ++
 3-riak/riak-1.2.0.tar.gz                    | Bin 0 -> 11208518 bytes
 8 files changed, 1325 insertions(+), 9 deletions(-)
 create mode 100644 3-riak/.kerl/archives/MD5
 create mode 100644 3-riak/.kerl/archives/otp_src_R15B01.tar.gz
 create mode 100644 3-riak/Vagrantfile
 create mode 100755 3-riak/kerl
 create mode 100755 3-riak/provision.sh
 create mode 100644 3-riak/readme.md
 create mode 100644 3-riak/riak-1.2.0.tar.gz
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