# build-sh
Fast and simple build script for C/C++ projects.

## Usage

1. Create project directory
```
~$ mkdir newproject
~$ cd newproject
```

2. Download build script and make it executable
```
~/newproject$ wget https://raw.githubusercontent.com/MrWeb123/build-sh/master/build.sh
~/newproject$ chmod +x build.sh
```

3. Run build script
```
~/newproject$ ./build.sh
~/newproject$ ls
bin  build.cfg  build.sh  src
```
Script created some dirs and files for your project:
* bin/      - this directory is used for storing output files
* src/      - source code directory
* build.sh  - build script
* build.cfg - config file used by build script. It contains flags for compiler.

4. Edit your files and run script again
```
~/newproject$ vim ./src/main.c
~/newproject$ ./build.sh
~/newproject$ ls -R
bin/main.o  build.cfg  build.sh  newproject  src/main.c
```
* newproject  - executable compiled from ./src/main.c
* bin/main.o  - output file
* src/main.c  - source file

5. Thats it! Everything works as it should be. You can now modify your code and repeat compilation without a hassle.
```
~/newproject$ ./newproject
Hello World!
```

## Features
* Fast shell script, no external libraries or anything like that
* separate config file for build management
* smart compiling based on last edited files
* Works in bash >= 4.0

## Config file
Config file is as simple as possible because it contains ony few informations:

* Executable file name  - [EXEC_NAME]
* Compiler command      - [COMPILER]
* Compiler flags        - [COMPILER_FLAGS]
* Linker command        - [LINKER]
* Linker flags          - [LINKER_FLAGS]

Every other tag in braskets will be ignored.
Value for each tag can be spanned on multiple lines

Example
```
# Default build.cfg file created at sob, 27 lut 2016, 22:33:35 CET
[EXEC_NAME]
runthis

[COMPILER]
gcc

[COMPILER_FLAGS]
# -c flag is very important!
-c
-g
-std=c11

[LINKER]
gcc

[LINKER_FLAGS]
-L/usr/lib
```

Comments are marked by '#' sign and they must start in new line.
```
[COMPILER_FLAGS]
# valid comment
-Wall # this is *INVALID*
```
