build-sh
========
### Fast and simple build script for C/C++ projects.

It works similarly to GNU Make and it is great for short and simple apps with few source files.

## Features
  * simple configuration file for compiler flags
  * rebuilds only modified files

## Usage
##### 1. Create project directory
```bash
mkdir newproject
cd newproject
```


##### 2. Download build script and make it executable
```shell
wget https://raw.githubusercontent.com/arturtamborski/build-sh/master/build.sh
chmod u+x build.sh
```


##### 3. Run build script
```
./build.sh
ls
bin  build.cfg  build.sh  src
```

Script created some dirs and files for your project:
* `bin/`        - directory for object / binary files
* `src/`        - directory for source files
* `build.sh`    - build script
* `build.cfg`   - configuration file used by build script


##### 4. Edit your files and run script again
```
vim ./src/main.c
./build.sh
ls -R
bin/main.o  build.cfg  build.sh  newproject  src/main.c
```
* `newproject`  - executable compiled from object files (named after current directory)
* `bin/main.o`  - output file
* `src/main.c`  - source file


##### 5. That's it! Now you can modify your code and repeat compilation without a hassle.
```
./newproject
Hello World!
```



## Configuration file
  * `[EXEC_NAME]`       - Executable file name
  * `[COMPILER]`        - Compiler command
  * `[COMPILER_FLAGS]`  - Compiler flags
  * `[LINKER]`          - Linker command
  * `[LINKER_FLAGS]`    - Linker flags

Other tags will be ignored. Values can span over several lines.

Comments are marked by '#' sign and they must start in new line.
```cfg
[COMPILER_FLAGS]
# valid comment
-Wall # this is *INVALID*
```

Example:
```cfg
[EXEC_NAME]
# here you can change the default name for compiled app
# if you don't want it to be set to default then remove this tag
mysuperappname

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
-lreadline
```


## Smart compiling
Script compares modification time of source file and corresponding object file, then it checks which one was modified first.

If source file was modified after object file then it needs to be recompiled,
but if source file was not modified since creation of corresponding object file then it can be skipped.

If you would like to do full build then just remove `/bin` directory or delete every file in it.
```shell
rm -r ./bin
./build.sh # build all
```


## Vim integration
You can put those lines in .vimrc to make simple binds to build script.
```cfg
" <F7> Will run full build
nnoremap <F7> :!rm -r ./bin && ./build.sh <CR>

" <F8> Will run smart build
nnoremap <F8> :!./build.sh <CR>

" Super hacky thing(TM) to run compiled program by calling :!./thing
" where thing is the last directory from current working path.
" Works great with ./build.sh but only if you **do not** change [EXEC_NAME] tag.
let out_program = "./" . system("basename `pwd`")
nnoremap <F9> :exe ":!" . out_program <CR>
```

## TODO
 * add support for multiple files with same names that are placed in different directories
 * add more customization in `build.cfg`?
 * check modification of header files and recompile files that use twhem
 * add a way to define verbosity and pretty printing
