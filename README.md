# Welcome to this Repo

Source code and modified `nench.sh` for https://benchmarks.gaab-networks.de.
Everything except the API is open source, so have fun with it.

If you want to contribute just use `curl https://benchmarks.gaab-networks.de/benchmark_api.sh | bash`

# Libaries and Licenses: 
- sorttable.js => MIT by Stuart Langridge
- Bootstrap 4.0 => MIT by The Bootstrap Authors & Twitter, Inc.
- jquery.js => MIT by JS Foundation
- popper.min.js => MIT by Federico Zivolo
- benchmark_api.sh (nench.sh) => Apache 2.0 
- benchmark_api.sh (Modifications) => GNU AGPLv3
- Everything else in this Repo => GNU AGPLv3 

If you are the Owner of one of the things mentioned above and you don't want me to have this in this Repo, please contact me. 

# Current Formula for the SIX

`((RAMCOUNT/1000)+((DISK_SPACE_AVAILABLE/1024/1024/1024)/(DD_AVG*IOPING_AVG)*100000000)+(CPU_CORES*((SHA256+BZIP2+AES)/3))/1000`

It's really good, I know
