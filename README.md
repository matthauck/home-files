# home-files

A simple script to put .vim, .profile, and .gitconfig files in place, as well as install some basic packages to get started with. 

Just run:

    /path/to/home-files/setup.sh

You can also add a file `~/conf.sh` which will inject custom environment variables into profile.sh 
for sensitive info that shouldn't be put on github. This file can also modify `TERMINAL_COLOR`, which gets put into `$PS1`!
