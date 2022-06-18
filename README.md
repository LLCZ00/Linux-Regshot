# Regshot, but for Linux
### linShot.sh
Identifies changes made to a filesystem by an executable, meant for dynamic malware analysis.<br/>
## Usage
```
./linShot.sh [option] FILENAME

Options:
  -h, --help                          show usage (this page)
  
  -d, --directory=/DIRECTORY/PATH     directory to search
                                      (default: current working directory)
                                      
  -t, --timeout=30                    time before executable timeout (s)
                                      (default: 10)
Examples:
	linShot malware.sh
	linShot -t 15 malware
	linShot -d /home /root/malware.o
	linShot --directory=/usr/bin --timeout=15 malware"
```
Output:
```
$ ./linShot -d /home/randy -t 15 susFile
~~~~~linShot Results~~~~~

Executable: /home/randy/Desktop/susFile
Searching: /home/randy

New Files:
        /home/randy/d1/d1_1/foo

Modified (and/or new) Files:
        /home/randy/d1/d1_1/bar.txt

Permissions changed:
        /home/randy/d1/foobar
        /home/randy/d1/d1_1/d1_1_1/barfoo

```
## Additional Details
linShot.sh runs the executable, then *attempts* to return the full path every file that was added, modified, and/or had its permissions changed by said executable.<br/>
Should only be used on a virtual machine, or anywhere reverting the system state is possible.
## Issues & TODO
- Changing the contents of a file may affect both modified and changed time, so if a file had its permissions
 changed before its contents were altered, the file will only show up in the modified section of the results.
- Access time is not checked because filesystems on linux are mounted with noatime or relatime by default,
 so access time is only updated when the modify time is changed.
 Changing it to strictatime will fix this, but will lead to an increased I/O burden, 
 and so it is not included in linshot.
- Does not work with *find* version 4.4.2 (use find --version)
