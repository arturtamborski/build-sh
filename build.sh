#!/bin/bash
# info: Simple build script for C/C++ projects.
#       Written by Artur Tamborski <tamborskiartur@gmail.com>
# date: 27.02.2016
# warn: Its wery specific script, it may not work for all projects.
#       You should use cmake instead. This script uses basename command.
#
# inpt: src dir in which should be source files with extention .cpp or .cc     
#       bin dir in which obj files will be stored after compilation
# outp: Compiled executable named after directory in which build-CPP is.
#       You can resolve it by executing in shell this command
#       $ echo | basename `pwd`

################################################################################
# info: those variables should hold paths to source code directory,
#       header files directory and binary output directory
# note: This string should *not* end with forward slash! (pwd works like this)
#       example: src_dir="./src" # no forward slash at end!!!
src_dir="./src"
inc_dir="./src"
bin_dir="./bin"

################################################################################
# info: config file used by this build script, contains flags for compiler
config="./build.cfg"

################################################################################
# info: default config file, will be created if no config file is found.
defaultcfg="# Default build.cfg file created at $(date)
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
"
################################################################################
#
#                       I M P L E M E N T A T I O N
#
################################################################################
# info: arrays for source and header files
src_files=()
inc_files=()
bin_files=()

################################################################################
# info: project and compilation metadata
project_name="$(basename `pwd`)"
project_time="$(date +%s)"
exec_name=""

################################################################################
# info: program used to compile
compiler=""

################################################################################
# info: shell command used to compile source files
compiler_flags=""

################################################################################
# info: shell command used to compile source files
linker=""

################################################################################
# info: shell command used to link compiled files
linker_flags=""

################################################################################
# info: colors for output.  color_e - error,    color_w - warning 
#                           color_i - info,     color_d - default
# note: see 'man tput' for more
# todo: change this to functions
color_e="printf $(tput setaf 1)"
color_w="printf $(tput setaf 3)"
color_i="printf $(tput setaf 2)"
color_d="printf $(tput sgr0)"

################################################################################
# info: string used to print lines
#       color_l - color_line 
#       color_r - color_ruler
# note: replace only last character (=)
# todo: change this to function parameter
color_l="%0.s="

################################################################################
# info: variable used to print lines
#       print_l - print line  ex: ===================
#       print_r - print ruler ex: -------------------
# note: it will print exactly 'width of terminal' characters
# warn: this variable needs tput to work
# todo: change this to function
print_l="printf $color_l $(seq 1 $(tput cols))"

################################################################################
# info: function prints user information about this script
print_info() {
    clear
    $color_i
    $print_l
    echo "Build script for C/C++ project"
    echo "Name: $project_name"
    echo "Time: $(date)"
    $print_l
}

################################################################################
# info: create bin, src & inc directories and build.cfg
create_build_files() {
    $color_i
    echo "Creating project files..."

    if [[ ! -e "$config" ]]; then
        $color_e
        touch $config
        if [[ ! -e "$config" ]]; then
            echo "Can't create default config file. Exiting..."
            fatal_error
        fi
        echo "$defaultcfg" >> "$config"

        $color_i
        echo "    Created default config file"
    fi

    for dir in "$bin_dir" "$inc_dir" "$src_dir"; do
        if [[ ! -d "$dir" ]]; then
            $color_e
            mkdir "$dir" &
            wait $!
            if [[ ! -d "$dir" ]]; then
                echo "Can't create $dir directory. Exiting..."
                fatal_error
            fi

            $color_i
            echo "    Created $dir directory"

            # note: if created src_dir then there is no point in compilation
            if [[ "$dir" == "$src_dir" ]]; then
                summary
            fi
        fi
    done
}

################################################################################
# info: parse config file for build script
parse_config() {
    $color_i
    echo ""
    echo "Parsing project config file..."
    $color_e

    local tag=""
    IFS=""
    while read -r line; do
        case $line in
            "[COMPILER]")                   ;& # note: falltrough works
            "[COMPILER_FLAGS]")             ;& #       only in bash >= 4.0
            "[LINKER]")                     ;&
            "[LINKER_FLAGS]")               ;&
            "[EXEC_NAME]")       tag=$line  ;;
            "#"*)                           ;; # ignore comments
            "["*)                           ;; # ignore unknown tags
            *)
                case $tag in
                    "[COMPILER]")       compiler="$compiler $line"            ;;
                    "[COMPILER_FLAGS]") compiler_flags="$compiler_flags $line";;
                    "[LINKER]")         linker="$linker $line"                ;;
                    "[LINKER_FLAGS]")   linker_flags="$linker_flags $line"    ;;
                    "[EXEC_NAME]")      exec_name="$line"                     ;;
                    *)                  echo "ERROR:wtf $line | $tag"         ;;
                esac
        esac
    done < $config
    unset IFS

    if [[ "$exec_name" == "" ]]; then
        exec_name="$project_name"
    fi

    $color_i
    echo "    Parsed: $config"
}
################################################################################
# info: function validates src directory
find_src_files() {
    $color_i
    echo ""
    echo "Searching for source code files..."
    $color_e

    # note: this is magic, don't touch this, just enjoy.
    # from: http://mywiki.wooledge.org/BashFAQ/020
    local i=""
    while IFS= read -r -d '' file; do
        $color_i
        echo "    Found: $file"
        src_files[i++]="$file"
    done < <(find $src_dir -type f \( -name '*.cpp' -o -name '*.cc' -o -name '*.c' \) -follow -print0)
    unset IFS
}

################################################################################
# info: finds all header files in inc_dir directory.
find_inc_files() {
    $color_i
    echo ""
    echo "Searching for include files..."
    $color_e

    # note: this is magic, don't touch this, just enjoy.
    # from: http://mywiki.wooledge.org/BashFAQ/020
    local i=""
    while IFS= read -r -d '' file; do
        $color_i
        echo "    Found: $file"
        inc_files[i++]="$file"
    done < <(find $inc_dir \( -name '*.hpp' -o -name '*.h' \) -type f -follow -print0)
    unset IFS
}

################################################################################
# info: finds all .o files in bin_dir
find_bin_files() {
    $color_i
    echo ""
    echo "Searching for binary output files..."
    $color_e

    # note: this is magic, don't touch this, just enjoy.
    # from: http://mywiki.wooledge.org/BashFAQ/020
    local i=""
    while IFS= read -r -d '' file; do
        $color_i
        echo "    Found: $file"
        bin_files[i++]="$file"
    done < <(find $bin_dir -name '*.o' -type f -follow -print0)
    unset IFS
}

################################################################################
# info: function compares obj files to src and inc files
# todo: compare to inc files
compare_files() {
    $color_i
    echo ""
    echo "Skipping unmodified files..."
    $color_e

    local i="0"
    for ((; $i<${#src_files[@]}; i++)); do
        local src_file="${src_files[$i]}"
        local bin_file="$bin_dir/$(basename ${src_files[$i]%.*}).o"

        if [[ -e "$bin_file" && -e "$src_file" ]]; then
            local bin_stat="$(stat -c %Y $bin_file)"
            local src_stat="$(stat -c %Y $src_file)"
            local diff="$(expr $src_stat - $bin_stat)"

            # note: if src file was modified before creation of obj file
            #       then there is no need for compilation of that file
            if [[ "$diff" -lt "0" ]]; then
                $color_i
                echo "    Skipped: $src_file"

                # note: string "__SKIPPED__" will be used later as a flag
                src_files[$i]+="__SKIPPED__"
            fi
        fi
    done
}

################################################################################
# info: function removes old obj files for compilation
# error: doesnt work !
cleanup_files() {
    $color_i
    echo ""
    echo "Removing modified output files..."
    $color_e

    # note: clean up modified output files
    local i="0"
    for ((; $i<${#src_files[@]}; i++)); do
        local src_file="${src_files[$i]}"

        if [[ "${src_files[$i]}" != *"__SKIPPED__" ]]; then
            local bin_file="$bin_dir/$(basename ${src_files[$i]%.*}).o"

            if [[ -e "$bin_file" ]]; then
                $color_e
                rm "$bin_file" &
                wait $!

                $color_i
                echo "    Removed: $bin_file"
            fi
        else
            # note: clear this because it should be ignored later
            src_files[$i]=""
        fi
    done

    # note: clean up exec file
    if [[ -e "$project_name" ]]; then
        $color_e
        rm "$project_name" &
        wait $!
        if [[ -e "$project_name" ]]; then
            echo "Can't remove $project_name Exiting..."
            fatal_error
        fi
    fi
}

################################################################################
# info: function compiles source code
compile_code() {
    $color_i
    echo ""
    echo "Compiling project..."
    $color_e

    # process files here
    local i="0"
    for ((; $i<${#src_files[@]}; i++)); do
        local src_file="${src_files[$i]}"

        if [[ "$src_file" != "" ]]; then
            local bin_file="$bin_dir/$(basename ${src_files[$i]%.*}).o"

            $color_i
            echo "    Compiling: $src_file"
            $color_e

            # execute compilation for each file
            local cmd="$compiler
                $compiler_flags
                -I$inc_dir
                -o$bin_file
                $src_file"

            exec $cmd &
            wait $!

            if [[ "$?" -ne "0" ]]; then
                $color_e
                echo "Compilation failed!"
                fatal_error
            fi

            if [[ ! "${bin_files[@]}" =~ "$bin_file" ]]; then
                local i="$(expr ${#bin_files[@]} + 1)"
                bin_files[$i]+="$bin_file"
            fi
        fi
    done
}

################################################################################
link_code() {
    $color_i
    echo ""
    echo "Linking project..."
    $color_e

    local files_all=""
    local cnt="0"
    for i in ${bin_files[@]}; do
        if [[ "$i" != "" ]]; then
            files_all="$files_all $i"
            cnt="$(expr $cnt + 1)"
        fi
    done

    if [[ "$cnt" -gt "0" ]]; then

        local cmd="$linker
            -I$inc_dir
            -o$exec_name
            $files_all
            $linker_flags"
        
        exec $cmd &
        wait $!

        if [[ "$?" -ne "0" ]]; then
            $color_e
            echo "Linking failed!"
            fatal_error
        fi
    fi
}

################################################################################
# info: timestamp for script
timestamp() {
    local time_end=$(date +"%s")
    local time_diff=$(($time_end-$project_time))

    echo "Time: $(date)"
    echo ""
    echo "$(($time_diff / 60)) minutes and $(($time_diff % 60)) seconds elapsed"
}

################################################################################
# info: summary of building process
# note: call only when everything passed successfully
#       returns 0 (exit error status)
summary() {
    if [[ ! -e "$project_name" ]]; then
        fatal_error
    fi

    $color_i
    $print_l

    echo "Build script passed!"
    timestamp

    $print_l
    $color_d

    exit 0
}

################################################################################
# info: call this function to quit script
# note: returns 1 (exit error status)
fatal_error() {
    $color_e
    $print_l

    echo "Build script failed!"
    timestamp

    $print_l
    $color_d

    exit 1
}

################################################################################
# info: script execution flow
# note: there is fatal_error() function but dont call it from this place
#       rather use it in other functons to report errors
# warn: do not modify order of those functions!
print_info
create_build_files
parse_config
find_src_files
find_inc_files
find_bin_files
compare_files
cleanup_files
compile_code
link_code
summary

################################################################################
