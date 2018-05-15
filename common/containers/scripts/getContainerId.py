import subprocess
import os
from io import StringIO

subprocess.call("docker ps -l | head -2 | tail -1 > line.txt", shell=True, env=os.environ)
text_file = open("line.txt", "r")
id = text_file.read().split(" ")[0]
print(id)
#str = "docker commit " + id + " liefeld/test"
#print(str)
#subprocess.call(str, shell=True, env=os.environ )

# the container is saved, now login to docker

#subprocess.call("aws ecr get-login --no-include-email --profile genepattern > dockerlogin.sh", shell=True, env=os.environ)
#subprocess.call("sh dockerlogin.sh", shell=True, env=os.environ)

