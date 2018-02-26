# deploy-saltstack
Tip: fix -bash: ./myscript: /bin/bash^M: bad interpreter: No such file or directory [duplicate]
Solution:
sed -i -e 's/\r$//' scriptname.sh

