# docker-aws-common-scripts
common scripts for docker/aws batch containers used for GenePattern modules

# this uses git subtrees to add to other containers.  Refer to
https://medium.com/@v/git-subtrees-a-tutorial-6ff568381844
https://help.github.com/articles/splitting-a-subfolder-out-into-a-new-repository/


# to add to another docker container's repo as a subtree


git remote add common-aws https://github.com/genepattern/docker-aws-common-scripts.git

git subtree add --prefix common common-aws master


# to update from this repo

git subtree pull --prefix common common-aws master --squash

# or if you did not add the remote

git subtree pull --prefix common  https://github.com/genepattern/docker-aws-common-scripts.git  master --squash



# to checkin from the docker's subtree to this repo

git subtree push --prefix common common-aws push-from-docker-java17

# to register a new or update a job definition when in a folder with the jobdef.json file 

aws batch register-job-definition --cli-input-json file://jobdef.json  --profile genepattern


