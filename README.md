csse7411
========
Test- > Romaan Added

The repository has the source code organized in the following directories:
1. raspi - Contains all the source code related to raspberry pi
2. zigdui - Contains all the source code related to zigduino mote
3. andro - Contains all the source code related to android phone
4. docs - Overall architecture and design describing how the modules communicate with each other

We have created a single repository to make all three sub-modules because:
(1) It is simple (rather than going to git submodules)
(2) Any change in any part of the sub-modules leads to an increase in commit and we can use a single versioning (tag)

The sub-folder, code design, setup and how to run is explained inside the docs folder present inside the above mentioned 4 directories.


-----------------------------
How to use Git during development

(1) Start with - Clone the repository
git clone https://github.com/csse7411/csse7411.git 

(2) Everytime we want to change the code
   (a) Create a branch
       git checkout -b <task1>
   (b) Make changes to file
   (c) Based on status
       git status
   (d) Add/Remove files to git
       git add|remove file1 file2 file3 ...
   (e) Create Commits
       git commit -m "Commit message"
   (f) Before pushing the code, ensure we have the latest copy
       git checkout master
       git pull origin master
   (g) Move to our branch
       git checkout <task1>
       git rebase master
   (h) If there are conflict, look for git status and resolve it, create a commit again, repeat from step (c), else step (i)
   (i) Change back to master and merge
       git checkout master
       git merge <task1>
   (j) Push the code
       git push origin master
   (k) Delete the branch we created at the start locally
       git branch -d <task1>
--------------------------------
