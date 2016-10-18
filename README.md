build-sh
========
### Fast and simple build script for C/C++ projects.
It works kind of like GNU Make. Great for simple projects with multiple files.

## Features
  * Fast, in-shell script.
  * Separate config file for build management.
  * Smart compiling based on last edited files.

## Usage
##### 1. Create project directory
```bash
~$ mkdir newproject
~$ cd newproject
```


##### 2. Download build script and make it executable
```shell
~/newproject$ wget https://raw.githubusercontent.com/arturtamborski/build-sh/master/build.sh
~/newproject$ chmod +x build.sh
```


##### 3. Run build script
```
~/newproject$ ./build.sh
~/newproject$ ls
bin  build.cfg  build.sh  src
```
Script created some dirs and files for your project:
* `bin/`        - this directory is used for storing output files
* `src/`        - source code directory
* `build.sh`    - build script
* `build.cfg`   - config file used by build script. It contains flags for compiler.


##### 4. Edit your files and run script again
```
~/newproject$ vim ./src/main.c
~/newproject$ ./build.sh
~/newproject$ ls -R
bin/main.o  build.cfg  build.sh  newproject  src/main.c
```
* `newproject`  - executable compiled from ./src/main.o
* `bin/main.o`  - output file
* `src/main.c`  - source file


##### 5. That's it! You can now modify your code and repeat compilation without a hassle.
```
~/newproject$ ./newproject
Hello World!
```



## Config file
Config file is very simple because it contains only few tags:
  * `[EXEC_NAME]`       - Executable file name
  * `[COMPILER]`        - Compiler command
  * `[COMPILER_FLAGS]`  - Compiler flags
  * `[LINKER]`          - Linker command
  * `[LINKER_FLAGS]`    - Linker flags

Other tags in braskets will be ignored.
Value for each tag can span over several lines.

Example config file
```cfg
# Default build.cfg file created at sob, 27 lut 2016, 22:33:35 CET
[EXEC_NAME]
compiledapp.exe

[COMPILER]
/usr/bin/gcc

[COMPILER_FLAGS]
# -c flag is very important!
-c
-g
-std=c11

[LINKER]
/usr/bin/gcc

[LINKER_FLAGS]
-L/usr/lib
```


Comments are marked by '#' sign and they must start in new line.
```cfg
[COMPILER_FLAGS]
# valid comment
-Wall # this is *INVALID*
```


## Smart compiling
Its cool feature for speeding up compilation process.
Script compares modification time of src file and corresponding obj file
and checks which one was modified first.
If src file was modified after creation of obj file then it needs to be recompiled.
But if src file was not modified since creation of corresponding obj file then this file is skipped.

If you want to do full build then just remove `/bin` directory or delete every file in it.
```shell
~/newproject$ rm -r ./bin
~/newproject$ ./build.sh # full build
```


## Vim integration
You can put those lines in .vimrc to make simple binds to build script.
```cfg
" <F7> Will run full build
nnoremap <F7> :!rm -r ./bin && ./build.sh <CR>

" <F8> Will run smart build
nnoremap <F8> :!./build.sh <CR>

" Super hacky thing(TM) to run compiled program by calling :!./thing 
" where thing is path when vim was launched.
" Works great with ./build.sh but **do not** change [EXEC_NAME] tag.
let out_program = "./" . system("basename `pwd`")
nnoremap <F9> :exe ":!" . out_program <CR>
```

## TODO:
 * support way to having multiple files with same names in different directories for `/bin` dir.
 * more customization in `build.cfg`?
