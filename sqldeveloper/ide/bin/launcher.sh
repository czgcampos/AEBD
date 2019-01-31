 #!/bin/bash

#=============================================================================
#
# launcher.sh - Launcher script for Oracle FCP IDE.
#
# Copyright (c) 2000, 2016, Oracle and/or its affiliates. All rights reserved.
#
# Relative paths are resolved against the parent directory of this file.
#
# This script is not invoked directly.  Instead, it is sourced
# (via "source launcher.sh") from a product-specific script that defines
# variables and overrides functions to provide product-specific
# information.
#
# The following variables must be defined when launcher.sh is sourced:
# -  STARTING_CWD should point to the working directory at the time
#    of script invocation.  This is not necessarily the directory
#    containing the script.
# -  INVOKED_AS should be the absolute path of the outermost script
#    or symlink that ultimately sources launcher.sh.
# -  SCRIPT should be the absolute path of the actual product-specific
#    script file, after all symlinks are resolved.
#
# The .conf file is located using the following algorithm,
# 1) Check if there is a .conf file in the same directory as
#    INVOKED_AS with the same basename as INVOKED_AS.  If it exists,
#    use it.  Otherwise,
# 2) Check if there is a .conf file in the same directory as
#    SCRIPT with the same basename as SCRIPT.  If it exists, use it.
#    Otherwise,
# 3) Error out, reporting that no .conf file could be found.
#
# If a .conf file is found, launcher.sh cd's into the .conf file's
# directory before proceeding.
#
# The following functions may be overridden in the product-specific
# script (i.e. after sourcing launcher.sh) to provide product-specific
# information:
#
# -  GetFullProductName(), which is used in the launch banner text.
#
# -  GetShortProductName(), which is used in prompt, warning, and
#    error messages shown to the user.
#
# -  GetProductVersion(), which is used in computing the path of the
#    user .conf file and allows for storing user .conf files by version
#
# -  GetUserConfRootDirName(), the root of the user .conf file directories,
#    which is used in computing the path of the user .conf file; by
#    default this is '. + GetShortProductName()' with spaces converted
#    to underscores and the name lower cased.
#
# -  GetUserConfDirPath(), which points to the directory of the user
#    .conf file; by default this would be $HOME/ + GetUserConfRootDirName +
#    '/' + GetProductVersion.
#
# -  GetUserConfFileName(), the short name of the user .conf file, which
#    is used in computing the path of the user .conf file; by default
#    this is 'product.conf'.
#
# -  GetUserConfFileContents(), which can be used if the launcher wants
#    complete control over the contents of the user .conf file.
#
# -  GetExtraUserConfFileContents(), which can be used to add to the default
#    user .conf file contents.
#
# -  GetToolSpecificUserConfFileContents(), which can be used to write out
#    the contents of the tool specific override of the user .conf file in
#    case a tool is using a user .conf file that is shared with other tools.
#    The name of this tool specific override file is "the name of the launcher
#    minus any extension" + ".conf" and it is stored in the same directory
#    as the default user .conf file.
#
# -  GetInitialJavaMemory(), which can override the default setting of -Xms128m.
#    If you override this method, returning a different value, it will be
#    applied to both 32-bit and 64-bit JDK's and you should not override
#    the 32-bit and 64-bit specific methods below.
#
# -  GetMaximumJavaMemory(), which can override the default setting of -Xmx800m.
#    If you override this method, returning a different value, it will be
#    applied to both 32-bit and 64-bit JDK's and you should not override
#    the 32-bit and 64-bit specific methods below.
#
# -  GetInitial32bitJavaMemory(), which can define a setting for 32-bit JDK's.
#    If you override this method, you should also override GetInitial64bitJavaMemory()
#    with an appropriate value for 64-bit JDK's, and you should override
#    GetInitialJavaMemory and return an empty string there.
#
# -  GetInitial64bitJavaMemory(), which can define a setting for 64-bit JDK's.
#    If you override this method, you should also override GetInitial32bitJavaMemory()
#    with an appropriate value for 32-bit JDK's, and you should override
#    GetInitialJavaMemory and return an empty string there.
#
# -  GetMaximum32bitJavaMemory(), which can define a setting for 32-bit JDK's.
#    If you override this method, you should also override GetMaximum64bitJavaMemory()
#    with an appropriate value for 64-bit JDK's, and you should override
#    GetMaximumJavaMemory and return an empty string there.
#
# -  GetMaximum64bitJavaMemory(), which can define a setting for 64-bit JDK's.
#    If you override this method, you should also override GetMaximum32bitJavaMemory()
#    with an appropriate value for 32-bit JDK's, and you should override
#    GetMaximumJavaMemory and return an empty string there.
#
# -  GetCopyrightStartYear(), if the derived script wants a different copyright
#    start year in the banner other than 1997
#
# -  GetCopyrightEndYear(), if the derived script wants a different copyright
#    end year in the banner than the build year
#
# -  ShowExtraHelp(), which should echo additional help text to the
#    console.  This will be displayed when the -help or --help option
#    is passed to the launcher.
#
# -  ShowHelp(), if the derived script wants to emit its own help
#
# -  ProductHandlesHelp(), return 1 if the product spawned by the
#    derived script handles help, ShowHelp() will not be called in
#    that case.
#
# -  ProductHandlesVerbose(), return 1 if the product spawned by the
#    derived script handles -verbose, SetVerbose() will not be called in
#    that case.
#
# -  DisplayBanner(), if the derived script wants to emit its own banner
#
# -  ProductDisplaysBanner(), return 1 if the product spawned by the
#    derived script displays the banner, DisplayBanner() will not be called
#    in that case.
#
# -  GetMinimumMajorJavaVersion(), return the absolute minimum major Java version
#    necessary to run the product in the form 1.<version>, e.g. "1.8"; return
#    an empty String if no check for minimum major Java version should be performed.
#
# NOTE: GetDotJdkFileName(), which used to point to the file to store the user
# provided path to the JDK or JRE used for the product, is not used anymore.
# Instead any user provided JDK/JRE path is stored in the user .conf file
# in a SetJavaHome directive which the launcher will read on subsequent startups.
#
# For the typical usage of launcher.sh, see product-launcher.template
# or one of the actual product launchers (e.g. OH/jdev/bin/jdev).
#=============================================================================


#-----------------------------------------------------------------------------
#  Functions that the product-specific launcher may override.  See
#  description above for details.
#-----------------------------------------------------------------------------

GetFullProductName()
{
    echo "Oracle IDE Application"
}

GetShortProductName()
{
    echo "IDE"
}

GetProductVersion()
{
    echo "1.0.0.0.0"
}

# Get the root of the user .conf directories
GetUserConfRootDirName()
{
    echo ".`GetShortProductName | sed -e 's/ /_/g' | tr [:upper:] [:lower:]`"
}

# Get the path of the directory of the user .conf file
GetUserConfDirPath()
{
    echo "$HOME/`GetUserConfRootDirName`/`GetProductVersion`"
}

# Get the name of the user .conf file
GetUserConfFileName()
{
    echo "product.conf"
}

# Get the contents of the user .conf file IFF different than the default contents
GetUserConfFileContents()
{
    echo ""
}

# Add extra content at the end of the default user.conf file
GetExtraUserConfFileContents()
{
    echo ""
}

# Get the contents of the tool specific override of the user .conf file in
# case a tool is using a user .conf file that is shared with other tools
GetToolSpecificUserConfFileContents()
{
    echo ""
}

# Get the initial Java memory
GetInitialJavaMemory()
{
    echo ""
}

# Get the initial Java memory for 32-bit JDK's
GetInitial32bitJavaMemory()
{
    echo ""
}

# Get the initial Java memory for 64-bit JDK's
GetInitial64bitJavaMemory()
{
    echo ""
}

# Get the maximum Java memory
GetMaximumJavaMemory()
{
    echo ""
}

# Get the maximum Java memory for 32-bit JDK's
GetMaximum32bitJavaMemory()
{
    echo ""
}

# Get the maximum Java memory for 64-bit JDK's
GetMaximum64bitJavaMemory()
{
    echo ""
}

# This method was created to avoid the checkin script (ade ci) modifying the display banner
# copyright line because it was being treated like header info at the top of each file
GetCopyrightHeader()
{
    echo "Copyright (c)"
}

GetCopyrightStartYear()
{
    echo "1997"
}

GetCopyrightEndYear()
{
    echo "2017"
}

ShowExtraHelp()
{
    # NOP.  Product-specific launcher can override to add extra help text.
    echo ""
}

# Override and return 1 if product displays the banner
ProductDisplaysBanner()
{
  if [ "X$PRODUCT_DISPLAYS_BANNER" = "X" ]
  then
    return 0
  fi
  return $PRODUCT_DISPLAYS_BANNER
}

DisplayBanner()
{
    cat <<EOF  | sed -e 's/^ //'

  `GetFullProductName`
  `GetCopyrightHeader` `GetCopyrightStartYear`, `GetCopyrightEndYear`, Oracle and/or its affiliates. All rights reserved.

EOF
}

# Override and return 1 if product handles any help options
ProductHandlesHelp()
{
  if [ "X$PRODUCT_HANDLES_HELP" = "X" ]
  then
    return 0
  fi
  return $PRODUCT_HANDLES_HELP
}

ShowHelp()
{
    cat <<EOF
Options:

The following options must appear first:
-verbose               Show java command line options
-conf[igure] <fname>   Use the specified configuration file

The following options must appear last:
-classic               Use Classic as the Java VM
-hotspot               Use Hotspot client as the Java VM
-server                Use Hotspot server as the Java VM
-client                Use Hotspot client as the Java VM
--<directive>=<value>  Override a directive from the configuration file
-J<flag>               Pass <flag> directly to the runtime system
-migrate               Migrate user settings from a previous installation
EOF
    ShowExtraHelp
}

# Override and return 1 if product handles the -verbose options
ProductHandlesVerbose()
{
  if [ "X$PRODUCT_HANDLES_VERBOSE" = "X" ]
  then
    return 0
  fi
  return $PRODUCT_HANDLES_VERBOSE
}

# Override and return 0 if product cannot be restarted
ProductCanRestart()
{
  if [ "X$PRODUCT_CAN_RESTART" = "X" ]
  then
    return 1
  fi
  return $PRODUCT_CAN_RESTART
}

# Return the absolute minimum major Java version necessary to run
# the product in the form 1.<version>, e.g. "1.8", return an
# empty String if no check for a minimum major Java version
# should be performed.
# The Java code of the core IDE performs a check of both the
# major and the minor JDK version.
GetMinimumMajorJavaVersion()
{
  echo "1.8"
}

#=============================================================================
#
#  Internal implementation beyond this point - do not override
#
#=============================================================================

#-----------------------------------------------------------------------------
# Resolve: resolve relative paths in a conf file directive argument.
# Args:
#   1) A string containing zero or more relative paths to be resolved.
#
# Paths in conf file directive arguments are expected to be relative to the
# directory  containing the  conf file, but such paths cannot be naively passed
# to the JVM because the current directory when the JVM is launched may be a
# different directory. This function resolves relative paths embedded in
# arguments to absolute paths.
#
# A (Unix) relative path is a path that starts with "../" or "./". The following
# are examples of the arguments that need to be handled:
#   AddVMOption     -Xbootclasspath/p:../lib/lwawt.jar
#   AddVMOption     -Djava.endorsed.dirs=../../../oracle_common/modules/endorsed
#   AddJavaLibFile  ../../../jdeveloper/ide/lib/ide-boot.jar
#   AddVMOption     -Dide.cluster.dirs=../../../jdeveloper/netbeans/bridge/:../../../jdeveloper/netbeans/ide/
#   AddVMOption     -Dosgi.bundles=file:../lib/oracle.ide.osgi.jar@3:start
#   AddVMOption     -Xbootclasspath/p:../../../jdeveloper/rdbms/jlib/ojdi.jar
#   AddVMOption     -Doracle.ide.reportEDTViolations.exceptionsfile=./swing-thread-violations.conf
#
#-----------------------------------------------------------------------------
Resolve()
{
  # Only do this for strings that might contain relative paths
  local dotslash="./"
  local arg="$*"
  if [ "$arg" = "${arg%$dotslash*}" ]
  then
    echo "$*"
  else
    # We can't use the absolute $PWD path because it might have spaces in it
    # Instead make $PWD relative to the launching directory
    # Then make incoming path relative to that 'relative $PWD'
    # We save time by not recomputing the relative PWD while we
    # are in the same script
    local relative_pwd=""
    if [ "$LAST_PWD_MADE_RELATIVE" != "$PWD" ]
    then
      relative_pwd=`computeRelativePath "$PWD" "$LaunchDir"`
    else
      relative_pwd="$LAST_RELATIVE_PWD"
    fi

    if [ "$relative_pwd" = "" ]
    then
      echo "$*"
    else
      # Any occurrence of "../" or "./" that is not preceded by one of "-", ".",
      # "/", "$", a letter, a digit, or "_" starts a relative path.
      # Merging the four substitutions requires regular expression
      # features not supported in all environments.
      echo "$*" | sed -e "s|^[.][.]/|$relative_pwd/../|; s|^[.]/|$relative_pwd/|; s|\([^-./$\w]\)[.][.]/|\1$relative_pwd/../|g; s|\([^-./$\w]\)[.]/|\1$relative_pwd/|g"
    fi
  fi
}

computeRelativePath()
{
  # Canonicalize and remove trailing '/' if any
  pushd "$1" > /dev/null 2>&1
  MakeRelative=`pwd -P`
  popd > /dev/null 2>&1
  MakeRelative=`echo "$MakeRelative" | sed -e "s|\n||g"`
  MakeRelative=`echo "$MakeRelative" | sed -e "s|/$||g"`
  pushd "$2" > /dev/null 2>&1
  StartingDir=`pwd -P`
  popd > /dev/null 2>&1
  StartingDir=`echo "$StartingDir" | sed -e "s|\n||g"`
  StartingDir=`echo "$StartingDir" | sed -e "s|/$||g"`

  # Split paths into pieces separated by '/'
  local OLDIFS=$IFS
  IFS="/"

  local makeRelativeArrayLength=0
  local makeRelativeArray="makeRelativeArray"
  for piece in $MakeRelative
  do
    # Need to doubly quote in case path pieces have spaces
    eval ${makeRelativeArray}${makeRelativeArrayLength}="'$piece'"
    let makeRelativeArrayLength++
  done

  local startingDirArrayLength=0
  local startingDirArray="startingDirArray"
  for piece in $StartingDir
  do
    # Need to doubly quote in case path pieces have spaces
    eval ${startingDirArray}${startingDirArrayLength}="'$piece'"
    let startingDirArrayLength++
  done

  IFS=$OLDIFS

  # First skip the parts of the paths that are the same
  local i
  for (( i = 0; i < $makeRelativeArrayLength && i < $startingDirArrayLength; i++ ))
  do
    local makeRelativePiece=$(echo $(eval echo \$$makeRelativeArray${i}))
    local startingDirPiece=$(echo $(eval echo \$$startingDirArray${i}))
    if [ "$makeRelativePiece" != "$startingDirPiece" ]
    then
      break
    fi
  done

  # Then collect the dotdots
  local dotdots=""
  local j
  for (( j = i; j < $startingDirArrayLength ; j++ ))
  do
    dotdots="${dotdots}../"
  done

  #Then collect the rest
  local appendToEnd=""
  for (( j = i; j < $makeRelativeArrayLength; j++ ))
  do
    local makeRelativePiece=$(echo $(eval echo \$$makeRelativeArray${j}))
    appendToEnd="${appendToEnd}$makeRelativePiece/"
  done

  # Strip any trailing '/' and we're done
  appendToEnd=`echo $appendToEnd | sed -e "s|/$||g"`
  echo "${dotdots}${appendToEnd}"
}

#-----------------------------------------------------------------------------
# IncludeConfFile: conf file directive
# Args:
#   1) file name of another conf file to include
#
  #
# A .conf file can specify that it includes another .conf file.  This
# allows common configuration to be shared across IDE products. Relative paths
# within a conf file are resolved against its containing directory.
#-----------------------------------------------------------------------------
IncludeConfFile()
{
  if ( [ -f "$1" ] )
  then
    EchoIfVerbose "Reading file $1"
    # Broken up into steps to be able to handle paths with spaces
    local PARENT=$PWD
    local dirName=`dirname "$1"`
    cd "$dirName"
    local cur_last_pwd_made_relative="$LAST_PWD_MADE_RELATIVE"
    local cur_last_relative_pwd="$LAST_RELATIVE_PWD"
    if [ "$LAST_PWD_MADE_RELATIVE" != "$PWD" ]
    then
      LAST_PWD_MADE_RELATIVE="$PWD"
      LAST_RELATIVE_PWD=`computeRelativePath "$PWD" "$LaunchDir"`
      EchoIfVerbose "Computed new relative PWD: $LAST_RELATIVE_PWD"
    fi
    local baseName=`basename "$1"`
    source "./$baseName"
    cd "$PARENT"
    LAST_PWD_MADE_RELATIVE="$cur_last_pwd_made_relative"
    LAST_RELATIVE_PWD="$cur_last_relative_pwd"
    EchoIfVerbose "Done reading file $1"
  else
    echo "Unable to find configuration file \"$1\" in \"$PWD\""
  fi
}

#-----------------------------------------------------------------------------
# SetJavaHome: conf file directive
#-----------------------------------------------------------------------------
SetJavaHome()
{
  APP_JAVA_HOME="`Resolve $1`"
  EchoIfVerbose "SetJavaHome called: $APP_JAVA_HOME"
}

#-----------------------------------------------------------------------------
# SetJavaVM: conf file directive
#-----------------------------------------------------------------------------
SetJavaVM()
{
  APP_JAVA_VM="$1"
}

#-----------------------------------------------------------------------------
# SetDebug: subroutine for setting up jdev to run as a debuggee for a
#           remote debugger.
#-----------------------------------------------------------------------------

SetDebug()
{
  EchoIfVerbose "Listen for a debugger to attach at port 4000"
  AddVMOption "-agentlib:jdwp=transport=dt_socket,server=y,address=4000"
}

#-----------------------------------------------------------------------------
# AddVMOption: conf file directive to add VM option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddVMOption()
{
  EchoIfVerbose "Adding VM Option: $*"
  APP_VM_OPTS[${#APP_VM_OPTS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddVMOptionJRockit: conf file directive to add JRockit specific option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddVMOptionJRockit()
{
  APP_VM_OPTS_JROCKIT[${#APP_VM_OPTS_JROCKIT[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddVMOptionHotspot: conf file directive to add Hotspot specific option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddVMOptionHotspot()
{
  APP_VM_OPTS_HOTSPOT[${#APP_VM_OPTS_HOTSPOT[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddVMOptionHotspot8: conf file directive to add Hotspot (version 8) specific option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddVMOptionHotspot8()
{
  APP_VM_OPTS_HOTSPOT8[${#APP_VM_OPTS_HOTSPOT8[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddVM8Option: conf file directive to add VM (version 8) option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddVM8Option()
{
  APP_VM8_OPTS[${#APP_VM8_OPTS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddVM9Option: conf file directive to add VM (version 9) option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddVM9Option()
{
  APP_VM9_OPTS[${#APP_VM9_OPTS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddVM9OrHigherOption: conf file directive to add VM (version 9 or higher) option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddVM9OrHigherOption()
{
  APP_VM9_OR_HIGHER_OPTS[${#APP_VM9_OR_HIGHER_OPTS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddLinuxVM9OrHigherOption: conf file directive to add Linux VM
# (version 9 or higher) option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddLinuxVM9OrHigherOption()
{
  APP_LINUX_VM9_OR_HIGHER_OPTS[${#APP_LINUX_VM9_OR_HIGHER_OPTS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddMacVM9OrHigherOption: conf file directive to add Mac VM
# (version 9 or higher) option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddMacVM9OrHigherOption()
{
  APP_MAC_VM9_OR_HIGHER_OPTS[${#APP_MAC_VM9_OR_HIGHER_OPTS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddSolarisVM9OrHigherOption: conf file directive to add Solaris VM
# (version 9 or higher) option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
AddSolarisVM9OrHigherOption()
{
  APP_SOLARIS_VM9_OR_HIGHER_OPTS[${#APP_SOLARIS_VM9_OR_HIGHER_OPTS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# Add32VMOption: conf file directive to add 32 bit VM option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
Add32VMOption()
{
  APP_VM_OPTS_32[${#APP_VM_OPTS_32[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# Add64VMOption: conf file directive to add 64 bit VM option
# Args:
#   1) command-line option to include when invoking the JVM
#-----------------------------------------------------------------------------
Add64VMOption()
{
  APP_VM_OPTS_64[${#APP_VM_OPTS_64[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddVMAddModulesOption: conf file directive to add --add-modules option
# Args:
#   1) e.g java.activation
#-----------------------------------------------------------------------------
AddVMAddModulesOption()
{
  EchoIfVerbose "Adding VM_ADD_MODULEs option: $*"
  APP_VM_ADDMODULES_OPTS[${#APP_VM_ADDMODULES_OPTS[*]}]="$*"
}

#-----------------------------------------------------------------------------
# AddJavaLibFile: conf file directive
# Args:
#   1) pathname of jar/zip file or directory to add to the application
#      classpath
#-----------------------------------------------------------------------------
AddJavaLibFile()
{
  EchoIfVerbose "Adding Java Lib File: $*"
  if ( [ -f $1 ] || [ -d $1 ] )
  then
    if [ -z "${APP_CLASSPATH}" ]
    then
      APP_CLASSPATH="`Resolve $*`"
    else
      APP_CLASSPATH="${APP_CLASSPATH}:`Resolve $*`"
    fi
  fi
}

#-----------------------------------------------------------------------------
# AddJava9LibFile: conf file directive to add lib file when JDK version is 9
# Args:
#   1) pathname of jar/zip file or directory to add to the application
#      classpath
#-----------------------------------------------------------------------------
AddJava9LibFile()
{
  APP_JAVA9_LIBS[${#APP_JAVA9_LIBS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# AddJava9OrHigherLibFile: conf file directive to add lib file when JDK version is 9 or higher
# Args:
#   1) pathname of jar/zip file or directory to add to the application
#      classpath
#-----------------------------------------------------------------------------
AddJava9OrHigherLibFile()
{
  APP_JAVA9_OR_HIGHER_LIBS[${#APP_JAVA9_OR_HIGHER_LIBS[*]}]="`Resolve $*`"
}

#-----------------------------------------------------------------------------
# SetMainClass: conf file directive
#-----------------------------------------------------------------------------
SetMainClass()
{
  APP_MAIN_CLASS="$1"
}

#-----------------------------------------------------------------------------
# SetSkipJ2SDKCheck: conf file directive
#-----------------------------------------------------------------------------
SetSkipJ2SDKCheck()
{
  APP_SKIP_J2SE_TEST=$1
}

#-----------------------------------------------------------------------------
#  implementation details
#-----------------------------------------------------------------------------
EchoIfVerbose()
{
  if [ -n "${APP_VERBOSE_MODE}" ]
  then
    echo "$(date +"%H:%M:%S") $@"
  fi
}

AddAppOption()
{
  APP_APP_OPTS[${#APP_APP_OPTS[*]}]="$*"
}

SetVerbose()
{
  APP_VERBOSE_MODE="true"
}

GetDefaultJDK()
{
  #
  # Search for Java in the following order:
  #  0) $OIDE_JAVA_HOME. This serves as a global override.
  #  1) ../../jdk/bin/java. Some products have a shipped JDK in this directory.
  #  2) ../../../jdk/bin/java. Some products have a shipped JDK in this
  #     directory, and it points to the JDK for JDEVADF internal developers.
  #  3) $JAVA_HOME/bin/java. If JAVA_HOME is set, we should use that
  #     to determine the JDK to use.
  #  4) A java in /usr/java/jdk8*
  #  5) A java in /usr/java8* (AIX)
  #  6) Any java on the PATH.

  # We check environment variables are set before using them.
  EchoIfVerbose "Searching for JDK in various pre-defined places"

  if [[ -n "$OIDE_JAVA_HOME" && -f "$OIDE_JAVA_HOME/bin/java" ]]
  then
    tmpvar="$OIDE_JAVA_HOME/bin/java"
    EchoIfVerbose "Found JDK override in environment variable OIDE_JAVA_HOME: $tmpvar"
  else
    if [ -f "../../jdk/bin/java" ]
    then
      tmpvar="../../jdk/bin/java"
      EchoIfVerbose "Found JDK at ../../jdk: $tmpvar"
    else
      if [ -f "../../../jdk/bin/java" ]
      then
        tmpvar="../../../jdk/bin/java"
        EchoIfVerbose "Found JDK at ../../../jdk: $tmpvar"
      else
        local javaHome="$JAVA_HOME"
        # On the Mac there is an executable to find (the latest) JAVA_HOME
        if [[ -z "$javaHome" && "darwin" = `uname | tr [:upper:] [:lower:]` ]]
        then
          javaHome=`/usr/libexec/java_home`
        fi
        if [[ -n "$javaHome" &&  -f "$javaHome/bin/java" ]]
        then
          tmpvar="$javaHome/bin/java"
          EchoIfVerbose "Found JDK home at JAVA_HOME environment variable: $tmpvar"
        else
          # See if we can find /usr/java/jdk8*
          jdk=`ls /usr/java 2>/dev/null | grep jdk8 | sort -r | head -1`
          if [[ "X$jdk" != "X" && -f "/usr/java/$jdk/bin/java" ]]
          then
            tmpvar="/usr/java/$jdk/bin/java"
            EchoIfVerbose "Found JDK at /usr/java/jdk8: $tmpvar"
          else
            # See if we can find /usr/java8*
            jdk=`ls /usr 2>/dev/null | grep java8 | sort -r | head -1`
            if [[ "X$jdk" != "X" && -f "/usr/$jdk/bin/java" ]]
            then
              tmpvar="/usr/$jdk/bin/java"
              EchoIfVerbose "Found JDK at /usr/java8: $tmpvar"
            else
              # If all else fails, look on the path
              tmpvar=`which "java" 2>/dev/null`
              EchoIfVerbose "Looked for JDK on the path with which"
            fi
          fi
        fi
      fi
    fi
  fi

  #
  # Make sure java is not
  # a symlink to some other bin/java location somewhere, if it is
  # follow it, and follow it as long as the new path ends with /bin/java
  #
  # Once the new path for java has been determined, truncate the /bin/java
  # ending portion of it and set javahome with the trucated path
  #
  if [ -f "$tmpvar" ]
  then
    while [ -h "$tmpvar" ]
    do
        EchoIfVerbose "Found symlinked JDK, following symlink: $tmpvar"
        tmpvar2=`ls -ls "$tmpvar"`
        tmpvar2=`expr "$tmpvar2" : '.*-> \(.*\)$'`
        if [ `expr "$tmpvar2" : "\.\/"` -gt 0 -o `expr "$tmpvar2" : "\.\.\/"` -gt 0 -o `expr "$tmpvar2" : ".*/.*"` -le 0 ]
        then
          tmpvar="`dirname "$tmpvar"`/$tmpvar2"
        else
          tmpvar="$tmpvar2"
        fi
    done
    tmpvar=`expr "$tmpvar" : '\(.*\)\/bin\/[^\/]*$'`
    SetJavaHome "$tmpvar"
    EchoIfVerbose "Found existing default JDK $tmpvar"
  else
    EchoIfVerbose "No existing default JDK found"
  fi
}

CheckJavaHome()
{
  # if there is a knonw java home
  if [ "X$APP_JAVA_HOME" != "X" ]; then
    # we don't do a j2se check if the flag is set or
    # if the JDK is 1.9 or higher (which don't have a jre dir anymore
    if [[ "X$APP_SKIP_J2SE_TEST" != "X" || $(expr "${APP_JAVA_MAJOR_VERSION}" \>= "1.9" ) -eq 1 ]]
    then
      EchoIfVerbose "Checking if bin/java exists for ${APP_JAVA_HOME}"
      if [ -f "${APP_JAVA_HOME}/bin/java" ]
      then
        return 1
      fi
    else
      EchoIfVerbose "Checking if bin/java AND jre/bin/java exist for ${APP_JAVA_HOME}"
      if [[ -f "${APP_JAVA_HOME}/bin/java" && -f "${APP_JAVA_HOME}/jre/bin/java" ]]
      then
        return 1
      fi
    fi
    EchoIfVerbose "The CheckJavaHome check failed for ${APP_JAVA_HOME}"
  else
    EchoIfVerbose "No APP_JAVA_HOME defined in CheckJavaHome"
  fi
  return 0
}

# The full path of the user .conf file
GetUserConfFilePath()
{
  echo "`GetUserConfDirPath`/`GetUserConfFileName`"
}

#
# Writes out a tool specific override of a shared user .conf file
#
WriteToolSpecificUserConfFile()
{
  if [ "$USE_USER_CONF" = "1" ]
  then
    return
  fi

  if [ -f "$TOOL_SPECIFIC_USER_CONF_FILE" ]
  then
    return
  fi

  local contents="`GetToolSpecificUserConfFileContents`"
  if [ "X$contents" = "X" ]
  then
    return
  fi

  if [ ! -f "`GetUserConfDirPath`" ]
  then
    mkdir -p "`GetUserConfDirPath`"
    if [ "$?" != "0" ]
    then
      echo "Could not create tool specific .conf file directory `GetUserConfDirPath`"
      return
    fi
  fi

  EchoIfVerbose "Writing tool specific user .conf file $TOOL_SPECIFIC_USER_CONF_FILE"

  echo "$contents" > "$TOOL_SPECIFIC_USER_CONF_FILE"
  if [ "$?" != "0" ]
  then
    echo "Could not write to file $TOOL_SPECIFIC_USER_CONF_FILE"
    return
  fi
}

#
# Writes out a user .conf file if it doesn't exist yet
#
WriteUserConfFile()
{
  if [ "$USE_USER_CONF" = "1" ]
  then
    return
  fi

  if [ -f "$USER_CONF_FILE" ]
  then
    return
  fi

  if [ ! -f "`GetUserConfDirPath`" ]
  then
    mkdir -p "`GetUserConfDirPath`"
    if [ "$?" != "0" ]
    then
      echo "Could not create user .conf file directory `GetUserConfDirPath`"
      return
    fi
  fi

  EchoIfVerbose "Writing user .conf file $USER_CONF_FILE"

  local customContents="`GetUserConfFileContents`"
  if [ "X$customContents" = "X" ]
  then
    # module-overrides.xml in ide module will init this
    local defaultContents="##############################################################################
#
# The format of this file is:
#
# Directive  Value
#
# with one or more spaces between the directive and the value. This file
# can be in either UNIX or DOS format for end of line terminators. Use UNIX
# style '/' path separators, although on Windows some directives, such as
# SetJavaHome, can take '\' path separators.
#
##############################################################################

#
# By default, the product launcher will search for a JDK to use, and if none
# can be found, it will ask for the location of a JDK and store its location
# in this file. If a particular JDK should be used instead, uncomment the
# line below and set the path to your preferred JDK.
#
# SetJavaHome /path/jdk

#
# Specify the initial size, in bytes, of the memory allocation pool. This
# value must be a multiple of 1024 greater than 1MB. Append the letter k
# or K to indicate kilobytes, or m or M to indicate megabytes, or g or G
# to indicate gigabytes. The default value is chosen at runtime based on
# the system configuration.
# Examples:  -Xms6291456
#            -Xms6144k
#            -Xms6m
#
# You can specify one value for any JDK using AddVMOption, OR you can specify
# separate values for 32-bit and 64-bit JDK's.
#
@@ADDVMOPTION_INITIAL_JAVA_MEMORY@@
@@ADD32VMOPTION_INITIAL_JAVA_MEMORY@@
@@ADD64VMOPTION_INITIAL_JAVA_MEMORY@@

#
# Specify the maximum size, in bytes, of the memory allocation pool. This
# value must be a multiple of 1024 greater than 2MB. Append the letter k
# or K to indicate kilobytes, or m or M to indicate megabytes, or g or G
# to indicate gigabytes. The default value is chosen at runtime based on
# the system configuration.
# Examples:  -Xmx83886080
#            -Xmx81920k
#            -Xmx80m
# On Solaris 7 and Solaris 8 SPARC platforms, the upper limit for this value
# is approximately 4000m minus overhead amounts. On Solaris 2.6 and x86
# platforms, the upper limit is approximately 2000m minus overhead amounts.
# On Linux platforms, the upper limit is approximately 2000m minus overhead
# amounts.
#
# If you are getting the 'Low Memory Warning' Message Dialog while running
# the product, please increase the -Xmx value below from the default 800M to
# something greater, like 1024M or 1250M.  If after increasing the value,
# the product is no longer starting up because it fails to create a virtual
# machine, then please reduce the modified -Xmx value, or use a 64bit JDK
# which allows for very very large value for -Xmx.
#
# You can specify one value for any JDK using AddVMOption, OR you can specify
# separate values for 32-bit and 64-bit JDK's.
#
@@ADDVMOPTION_MAXIMUM_JAVA_MEMORY@@
@@ADD32VMOPTION_MAXIMUM_JAVA_MEMORY@@
@@ADD64VMOPTION_MAXIMUM_JAVA_MEMORY@@
"

    # Update the initial Java Memory directives
    local initialJavaMemory="`GetInitialJavaMemory`"
    if [ "X$initialJavaMemory" = "X" ]
    then
      # We need to escape characters that are special for sed substitutions
      local escapedComment=$(printf '%s\n' "# AddVMOption -Xms128m" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADDVMOPTION_INITIAL_JAVA_MEMORY@@/$escapedComment/"`
    else
      # We need to escape characters that are special for sed substitutions
      local escapedDirective=$(printf '%s\n' "AddVMOption $initialJavaMemory" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADDVMOPTION_INITIAL_JAVA_MEMORY@@/$escapedDirective/"`
    fi
    initialJavaMemory="`GetInitial32bitJavaMemory`"
    if [ "X$initialJavaMemory" = "X" ]
    then
      # We need to escape characters that are special for sed substitutions
      local escapedComment=$(printf '%s\n' "# Add32VMOption -Xms128m" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADD32VMOPTION_INITIAL_JAVA_MEMORY@@/$escapedComment/"`
    else
      # We need to escape characters that are special for sed substitutions
      local escapedDirective=$(printf '%s\n' "Add32VMOption $initialJavaMemory" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADD32VMOPTION_INITIAL_JAVA_MEMORY@@/$escapedDirective/"`
    fi
    initialJavaMemory="`GetInitial64bitJavaMemory`"
    if [ "X$initialJavaMemory" = "X" ]
    then
      # We need to escape characters that are special for sed substitutions
      local escapedComment=$(printf '%s\n' "# Add64VMOption -Xms128m" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADD64VMOPTION_INITIAL_JAVA_MEMORY@@/$escapedComment/"`
    else
      # We need to escape characters that are special for sed substitutions
      local escapedDirective=$(printf '%s\n' "Add64VMOption $initialJavaMemory" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADD64VMOPTION_INITIAL_JAVA_MEMORY@@/$escapedDirective/"`
    fi

    local maximumJavaMemory="`GetMaximumJavaMemory`"
    if [ "X$maximumJavaMemory" = "X" ]
    then
      # We need to escape characters that are special for sed substitutions
      local escapedComment=$(printf '%s\n' "# AddVMOption -Xmx800m" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADDVMOPTION_MAXIMUM_JAVA_MEMORY@@/$escapedComment/"`
    else
      # We need to escape characters that are special for sed substitutions
      local escapedDirective=$(printf '%s\n' "AddVMOption $maximumJavaMemory" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADDVMOPTION_MAXIMUM_JAVA_MEMORY@@/$escapedDirective/"`
    fi
    maximumJavaMemory="`GetMaximum32bitJavaMemory`"
    if [ "X$maximumJavaMemory" = "X" ]
    then
      # We need to escape characters that are special for sed substitutions
      local escapedComment=$(printf '%s\n' "# Add32VMOption -Xmx800m" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADD32VMOPTION_MAXIMUM_JAVA_MEMORY@@/$escapedComment/"`
    else
      # We need to escape characters that are special for sed substitutions
      local escapedDirective=$(printf '%s\n' "Add32VMOption $maximumJavaMemory" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADD32VMOPTION_MAXIMUM_JAVA_MEMORY@@/$escapedDirective/"`
    fi
    maximumJavaMemory="`GetMaximum64bitJavaMemory`"
    if [ "X$maximumJavaMemory" = "X" ]
    then
      # We need to escape characters that are special for sed substitutions
      local escapedComment=$(printf '%s\n' "# Add64VMOption -Xmx800m" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADD64VMOPTION_MAXIMUM_JAVA_MEMORY@@/$escapedComment/"`
    else
      # We need to escape characters that are special for sed substitutions
      local escapedDirective=$(printf '%s\n' "Add64VMOption $maximumJavaMemory" | sed 's/[\&/]/\\&/g')
      defaultContents=`echo "$defaultContents" | sed "s/@@ADD64VMOPTION_MAXIMUM_JAVA_MEMORY@@/$escapedDirective/"`
    fi

    echo "$defaultContents" > "$USER_CONF_FILE"
    if [ "$?" != "0" ]
    then
      echo "Could not write to file $USER_CONF_FILE"
      return
    fi
    echo "" >> "$USER_CONF_FILE"

    local extraContents="`GetExtraUserConfFileContents`"
    if [ ! "X$extraContents" = "X" ]
    then
      echo "$extraContents" >> "$USER_CONF_FILE"
      echo "" >> "$USER_CONF_FILE"
    fi
  else
    echo "$customContents" > "$USER_CONF_FILE"
    if [ "$?" != "0" ]
    then
      echo "Could not write to file $USER_CONF_FILE"
      return
    fi
    echo "" >> "$USER_CONF_FILE"
  fi
}

#
# Assumes an argument which points to a Java Home
# Attempts to create a SetJavaHome directive with the new Java Home
# in the user .conf file
#
UpdateUserConfFileJavaHome()
{
  if [ "$USE_USER_CONF" = "1" ]
  then
    return
  fi

  if [ ! -f "$USER_CONF_FILE" ]
  then
    return
  fi

  EchoIfVerbose "Updating user .conf file '$USER_CONF_FILE' with SetJavaHome=$1"

  local contents="`cat $USER_CONF_FILE`"

  # We need to escape characters that are special for sed substitutions
  local escapedJavaHome=$(printf '%s\n' "$1" | sed 's/[\&/]/\\&/g')

  # First try to change an uncommented SetJavaHome directive
  local newContents=`cat "$USER_CONF_FILE" | sed "s/^[ ]*SetJavaHome[ ].*/SetJavaHome $escapedJavaHome/"`
  if [ "$newContents" = "$contents" ]
  then
    # If there was no uncommented SetJavaHome, try to change a commented out one
    newContents=`cat "$USER_CONF_FILE" | sed "s/^[ ]*#[ ]*SetJavaHome[ ].*/SetJavaHome $escapedJavaHome/"`
    if [ "$newContents" = "$contents" ]
    then
      # If we couldn't find any SetJavaHome, add it
      echo "" >> "$USER_CONF_FILE"
      if [ "$?" != "0" ]
      then
        echo "Could not update file $USER_CONF_FILE"
        return
      fi
      echo "SetJavaHome ${1}" >> "$USER_CONF_FILE"
      echo "" >> "$USER_CONF_FILE"
    else
      echo "$newContents" > "$USER_CONF_FILE"
      if [ "$?" != "0" ]
      then
        echo "Could not update file $USER_CONF_FILE"
        return
      fi
    fi
  else
    echo "$newContents" > "$USER_CONF_FILE"
      if [ "$?" != "0" ]
      then
        echo "Could not update file $USER_CONF_FILE"
        return
      fi
  fi
}

ListConfigFileChoices()
{
  if [ "$USE_USER_CONF" = "0" ]
  then
    echo "  ${USER_CONF_FILE}"
  fi
  echo "  ${APP_CONF_FILE}"
  if [ -f "${APP_PLATFORM_CONF_FILE}" ]
  then
    echo "  ${APP_PLATFORM_CONF_FILE}"
  fi
}

ExtractVersion()
{
  # We only extract the smallest major version. For versions before JDK9
  # we extract 1.<digits>, e.g. 1.8 and for JDK9 and higher, just <digits>
  # e.g. 9 or 10
  # The Java code in the core IDE has code to check versions in more details
  # including major and minor versions
  #
  local versionString="$1"
  local majorVersion=""
  local dotCount=0
  local digitCount=0
  for (( i=0; i<${#versionString}; i++)); do
    local oneChar=${versionString:$i:1}
    # If major version is '1' at the first dot, we want to grab one more number
    # otherwise we want to stop at the first dot
    if [ "$oneChar" = "." ]
    then
      if [ $dotCount -eq 0 ]
      then
        if [ $majorVersion = "1" ]
        then
          let dotCount++
          majorVersion="$majorVersion$oneChar"
          continue
        else
          break
        fi
      fi
      break
    # We only want dots and digits
    elif echo "$oneChar" | grep '[0-9]' >/dev/null
    then
      majorVersion="$majorVersion$oneChar"
      let digitCount++
    # Skip everything before the first digit
    elif [ $digitCount -eq 0 ]
    then
      continue
    else
      break
    fi
  done
  # Make sure we have a version number
  if [ $digitCount -eq 0 ]
  then
    echo ""
  else
    echo "$majorVersion"
  fi
}

GetJavaMajorVersion()
{
  APP_JAVA_MAJOR_VERSION=""
  local majorVersion=""
  APP_RELEASE_FILE="${APP_JAVA_HOME}/release"
  EchoIfVerbose "Getting major version from ${APP_RELEASE_FILE}"
  if [ -f ${APP_RELEASE_FILE} ]
  then
    local releaseFile="`cat $APP_RELEASE_FILE`"
    EchoIfVerbose "Contents of $APP_RELEASE_FILE: $releaseFile"
    for (( i=0; i+12<${#releaseFile}; i++)); do
      local releaseChar=${releaseFile:$i:1}
      if [ "$releaseChar" = "J" ]
      then
        local releaseString=${releaseFile:$i:12}
        if [ "$releaseString" = "JAVA_VERSION" ]
        then
          EchoIfVerbose "Found JAVA_VERSION property"
          majorVersion="`ExtractVersion ${releaseFile:$i}`"
          break
        fi
      fi
    done
  else
    EchoIfVerbose "$APP_RELEASE_FILE doesn't exist"
  fi
  if [ "$majorVersion" = "" ]
  then
    APP_JAVA_EXE="${APP_JAVA_HOME}/bin/java"
    EchoIfVerbose "Getting major version of Java executable ${APP_JAVA_EXE}"
    if [ -f ${APP_JAVA_EXE} ]
    then
      local versionString=`"${APP_JAVA_EXE}" -version 2>&1`
      EchoIfVerbose "Extracting Java version from $versionString"
      majorVersion="`ExtractVersion $versionString`"
    else
      EchoIfVerbose "Java executable ${APP_JAVA_EXE} doesn't exist"
    fi
  fi
  # Make sure we have a version number
  if [ "$majorVersion" = "" ]
  then
    EchoIfVerbose "No major Java version found, can't set APP_JAVA_MAJOR_VERSION"
  else
    APP_JAVA_MAJOR_VERSION="$majorVersion"
    EchoIfVerbose "Found Java major version: ${APP_JAVA_MAJOR_VERSION}"
  fi
}

# Check the JDK found has a major version higher than or equal to
# the minimum one allowed
#
HasMinimumMajorJavaVersion()
{
  local minimumMajorVersion="`GetMinimumMajorJavaVersion`"
  if [ ! "$minimumMajorVersion" = "" ]
  then
    EchoIfVerbose "Extracting minimum major Java version from $minimumMajorVersion"
    minimumMajorVersion="`ExtractVersion $minimumMajorVersion`"
    if [ ! "$minimumMajorVersion" = "" ]
    then
      EchoIfVerbose "Found minimum major Java version $minimumMajorVersion"
      # Make sure we have a APP_JAVA_MAJOR_VERSION
      if [ "X$APP_JAVA_MAJOR_VERSION" != "X" ]
      then
        if [ $(expr "$APP_JAVA_MAJOR_VERSION" \< "$minimumMajorVersion") -eq 1 ]
        then
          echo ""
          echo "Found ${APP_JAVA_EXE} to run this product, and the major version of this Java is $APP_JAVA_MAJOR_VERSION."
          echo "The mandatory minimum major version to run this product is $minimumMajorVersion."
          echo "This product cannot run with this Java."
          echo ""
          return 1
        else
          EchoIfVerbose "Major Java version of Java is $APP_JAVA_MAJOR_VERSION, which is bigger than/equal to minimum major Java version $minimumMajorVersion"
        fi
      else
        EchoIfVerbose "No APP_JAVA_MAJOR_VERSION found."
      fi
    else
      EchoIfVerbose "No minimum major Java version configured, check for minimum major Java version skipped"
    fi
  else
    EchoIfVerbose "Java executable ${APP_JAVA_EXE} doesn't exist"
  fi
  return 0
}

CheckJDK()
{
  # if the java home was defined, get the version for further checks
  if [ "X$APP_JAVA_HOME" != "X" ]
  then
    GetJavaMajorVersion
  fi

  # Now make the first checks to see if we should try to find a JDK
  if [ "X$APP_JAVA_HOME" = "X" ] || CheckJavaHome
  then
    # No java home defined or not a valid jdk, try to find another one
    # and then get the major java version again for further checks
    GetDefaultJDK
    if [ "X$APP_JAVA_HOME" != "X" ]
    then
      GetJavaMajorVersion
    fi
  fi

  # if java wasn't found on the path or if the major Java version
  # was too low, then ask the user for it
  local updateUserConfig=1
  if CheckJavaHome || ! HasMinimumMajorJavaVersion
  then
    EchoIfVerbose "Default JDK not found or not a valid JDK"
    APP_JAVA_HOME=""
    local count=0
    local lastPart=""
    if [ "$USE_USER_CONF" = "0" ]
    then
      lastPart=", the path will be stored in `GetUserConfFilePath`"
    fi
    while [ "X$APP_JAVA_HOME" = "X" ] && [ $count -lt 10 ]
    do
      let count++
      echo "Type the full pathname of a JDK installation (or Ctrl-C to quit)${lastPart}"
      read APP_JAVA_HOME
      if [ -f "${APP_JAVA_HOME}/bin/java" ]
      then
        GetJavaMajorVersion
        if HasMinimumMajorJavaVersion
        then
          updateUserConfig=0
          break
        fi
      fi
      echo "Error: ${APP_JAVA_HOME}/bin/java not found or not a valid JDK"
      APP_JAVA_HOME=""
    done
    if [ "X$APP_JAVA_HOME" = "X" ]
    then
      echo "Error:  Unable to get APP_JAVA_HOME input from stdin after 10 tries"
      exit 1
    fi
  fi

  APP_JAVA_EXE="${APP_JAVA_HOME}/bin/java"
  if [ -f ${APP_JAVA_EXE} ]
  then
    # We found an existing Java exe
    EchoIfVerbose "Found existing Java executable ${APP_JAVA_EXE}"

    # We don't do the following checks if the java major version >= 1.9
    # since those JDK's don't have a jre OR tools.jar OR dt.jar anymore
    # We don't do a j2se check if the flag is set
    if [[ "X$APP_SKIP_J2SE_TEST" = "X" && $(expr "${APP_JAVA_MAJOR_VERSION}" \< "1.9" ) -eq 1 ]]
    then
      if [[ ! -f "${APP_JAVA_HOME}/jre/bin/java" || ! -f "${APP_JAVA_HOME}/lib/tools.jar" || ! -f "${APP_JAVA_HOME}/lib/dt.jar" ]]
      then
        echo "Error: Java home ${APP_JAVA_HOME} is not a JDK,"
        echo "either jre/bin/java OR lib/tools.jar OR lib/dt.jar is missing."
        echo "Running `GetShortProductName` under a JRE is not supported."
        echo ""
        echo "If this Java VM is actually a full JDK installation, add"
        echo "'SetSkipJ2SDKCheck true' to one of the following files."
        echo "Otherwise specify a different Java JDK location with a"
        echo "SetJavaHome directive in one of the following files:"
        ListConfigFileChoices
        echo ""
        JAVA=""
        exit 1;
      fi
    fi

    # We found an existing and acceptable APP_JAVA_EXE!
    EchoIfVerbose "Found acceptable Java executable ${APP_JAVA_EXE}"
    # Need to add both tools.jar (for debugger) and dt.jar (for UI Editor e.g. bug 10332595),
    # but we don't do this in JDK1.9 or higher which don't have those jars
    if [ $(expr "${APP_JAVA_MAJOR_VERSION}" \< "1.9" ) -eq 1 ]
    then
      JAVA="${APP_JAVA_EXE} -Xbootclasspath/a:${APP_JAVA_HOME}/lib/tools.jar:${APP_JAVA_HOME}/lib/dt.jar "
    else
      JAVA="${APP_JAVA_EXE}"
    fi
    if [ "X$APP_JAVA_VM" != "X" ]
    then
      JAVA="${JAVA} -${APP_JAVA_VM} "
    fi
    if [ "$updateUserConfig" = "0" ]
    then
      UpdateUserConfFileJavaHome $APP_JAVA_HOME
    fi

    #Determine 32 or 64 bit
    local fileOutput=$(file "$APP_JAVA_EXE" | grep 64-bit)
    if [ "X$fileOutput" = "X" ]
    then
      JDK_BIT_SIZE="32"
    else
      JDK_BIT_SIZE="64"
    fi
  else
    echo "Error: No JDK found on PATH"
    echo "Please correct or add the SetJavaHome directive in one of the following files:"
    ListConfigFileChoices
    echo "to point to a JDK installation."
    echo ""
    JAVA=""
    exit 1;
  fi
}

CheckLibraryPath()
{
        #echo "Value of ORACLE_HOME is $ORACLE_HOME"
        #echo "Value of LD_LIBRARY_PATH is $LD_LIBRARY_PATH"

        if [ "X$ORACLE_HOME" = "X" ]
        then
                return
        fi

        if [ `uname -s` = 'HP-UX' ]
        then
                if [ "X$SHLIB_PATH" = "X" ]
                then
                        SHLIB_PATH=$ORACLE_HOME/lib
                else
                        echo $SHLIB_PATH | egrep -e "(^|\:)$ORACLE_HOME/lib($|\:)" > /dev/null
                        if [ $? != 0 ]
                        then
                                SHLIB_PATH=$SHLIB_PATH:$ORACLE_HOME/lib
                        fi
                fi
                export SHLIB_PATH
                #echo $SHLIB_PATH
        else
                if [ "X$LD_LIBRARY_PATH" = "X" ]
                then
                        LD_LIBRARY_PATH=$ORACLE_HOME/lib
                else
                        echo $LD_LIBRARY_PATH | egrep -e "(^|\:)$ORACLE_HOME/lib($|\:)" > /dev/null
                        if [ $? != 0 ]
                        then
                                LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib
                        fi
                fi
                export LD_LIBRARY_PATH
                #echo $LD_LIBRARY_PATH
        fi
}

#
# This method will add all the specific VM Options,  we support several VM specific options:
#    JRockit       <-- JRockit VM specific option
#    Hotspot       <-- Hotspot VM specific option
#    Hotspot8      <-- Jdk 8 Hotspot VM specific option
#    8             <-- Jdk 8 option
#    9             <-- Jdk 9 option
#    32            <-- 32-bit specific VM option
#    64            <-- 64-bit specific VM option
#
AppendVMSpecificOptions()
{
  local darwin=`uname | grep Darwin`
  local hotspotVM=""
  if [ "X$darwin" = "XDarwin" ]
  then
    hotspotVM=`ls ${APP_JAVA_HOME}/jre/lib/{server,client,hotspot} 2> /dev/null`
  else
    hotspotVM=`ls ${APP_JAVA_HOME}/jre/lib/*/{server,client,hotspot} 2> /dev/null`
  fi
  local jrockitVM=`ls ${APP_JAVA_HOME}/jre/lib/*/jrockit 2> /dev/null`
  if [ "X$hotspotVM" != "X" ] && [ "X$jrockitVM" = "X" ]
  then
    for (( i = 0; i < ${#APP_VM_OPTS_HOTSPOT[@]}; i++ )); do
      AddVMOption "${APP_VM_OPTS_HOTSPOT[$i]}"
    done
    local hotspotVMVersion=`grep 1\.[8]\.0 ${APP_JAVA_HOME}/release 2> /dev/null`
    local hotspotVMVersion=`expr "$hotspotVMVersion" : '.*\([8]\).*'`
    case $hotspotVMVersion in
      8) for (( i = 0; i < ${#APP_VM_OPTS_HOTSPOT8[@]}; i++ )); do
           AddVMOption "${APP_VM_OPTS_HOTSPOT8[$i]}"
         done ;;
    esac
  fi
  if [ "X$hotspotVM" = "X" ] && [ "X$jrockitVM" != "X" ]
  then
    for (( i = 0; i < ${#APP_VM_OPTS_JROCKIT[@]}; i++ )); do
      AddVMOption "${APP_VM_OPTS_JROCKIT[$i]}"
    done
  fi
  if [ "X$JDK_BIT_SIZE" = "X64" ]
  then
    for (( i = 0; i < ${#APP_VM_OPTS_64[@]}; i++ )); do
      AddVMOption "${APP_VM_OPTS_64[$i]}"
    done
  else
    for (( i = 0; i < ${#APP_VM_OPTS_32[@]}; i++ )); do
      AddVMOption "${APP_VM_OPTS_32[$i]}"
    done
  fi
  if [ "${APP_JAVA_MAJOR_VERSION}" = "1.8" ]
  then
    for (( i = 0; i < ${#APP_VM8_OPTS[@]}; i++ )); do
      AddVMOption "${APP_VM8_OPTS[$i]}"
    done
  fi
  if [[  "${APP_JAVA_MAJOR_VERSION}" = "1.9" || "${APP_JAVA_MAJOR_VERSION}" = "9" ]]
  then
    for (( i = 0; i < ${#APP_VM9_OPTS[@]}; i++ )); do
      AddVMOption "${APP_VM9_OPTS[$i]}"
    done
    for (( i = 0; i < ${#APP_JAVA9_LIBS[@]}; i++ )); do
      AddJavaLibFile "${APP_JAVA9_LIBS[$i]}"
    done
  fi
  if [ $(expr "${APP_JAVA_MAJOR_VERSION}" \>= "1.9" ) -eq 1 ]
  then
    EchoIfVerbose "Size of add modules options is ${#APP_VM_ADDMODULES_OPTS[@]}"
    if [ $(expr "${#APP_VM_ADDMODULES_OPTS[@]}" \> "0" ) -eq 1 ]
    then
      local addModulesOption="--add-modules="
      local oneComma=""
      for (( i = 0; i < ${#APP_VM_ADDMODULES_OPTS[@]}; i++ )); do
        addModulesOption="$addModulesOption$oneComma${APP_VM_ADDMODULES_OPTS[$i]}"
        oneComma=","
      done
      AddVMOption "$addModulesOption"
    fi
    for (( i = 0; i < ${#APP_VM9_OR_HIGHER_OPTS[@]}; i++ )); do
      AddVMOption "${APP_VM9_OR_HIGHER_OPTS[$i]}"
    done
    local machineUname=`uname | tr [:upper:] [:lower:]`
    if [ "linux" = "$machineUname" ]
    then
      for (( i = 0; i < ${#APP_LINUX_VM9_OR_HIGHER_OPTS[@]}; i++ )); do
        AddVMOption "${APP_LINUX_VM9_OR_HIGHER_OPTS[$i]}"
      done
    fi
    if [ "darwin" = "$machineUname" ]
    then
      for (( i = 0; i < ${#APP_MAC_VM9_OR_HIGHER_OPTS[@]}; i++ )); do
        AddVMOption "${APP_MAC_VM9_OR_HIGHER_OPTS[$i]}"
      done
    fi
    if [ "sunos" = "$machineUname" ]
    then
      for (( i = 0; i < ${#APP_SOLARIS_VM9_OR_HIGHER_OPTS[@]}; i++ )); do
        AddVMOption "${APP_SOLARIS_VM9_OR_HIGHER_OPTS[$i]}"
      done
    fi
    for (( i = 0; i < ${#APP_JAVA9_OR_HIGHER_LIBS[@]}; i++ )); do
      AddJavaLibFile "${APP_JAVA9_OR_HIGHER_LIBS[$i]}"
    done
  fi
}


#  This method should be called from the product-specific launcher to
#  do the .conf file processing and launch the IDE.
LaunchIDE()
{
    LaunchIDE_called=true
    readonly LaunchIDE_called

    LaunchDir=$PWD

    #:ValidateArgs:
    {
        if [ "X${STARTING_CWD}" = "X" ]
        then
            echo "ERROR: STARTING_CWD variable not defined."
            exit 1
        fi
        if [ "X${INVOKED_AS}" = "X" ]
        then
            echo "ERROR: INVOKED_AS variable not defined."
            exit 2
        fi
        if [ "X${SCRIPT}" = "X" ]
        then
            echo "ERROR: SCRIPT variable not defined."
            exit 3
        fi
    }

    USE_USER_CONF=0
    #:PrePreProcessArgs:
    {
      for arg in "$@"
      do
        case "$arg" in
          -nouserconf)
            USE_USER_CONF=1
          ;;
          --verbose)
            SetVerbose
          ;;
        esac
      done
    }

    EchoIfVerbose "Launching IDE"

    ProductDisplaysBanner
    HandlesBanner=$?
    if [ "$HandlesBanner" = "0" ]
    then
      DisplayBanner
    fi

    #:SetConfigFiles:
    {
        # Set user configuration file
        if [ "$USE_USER_CONF" = "0" ]
        then
          USER_CONF_FILE="`GetUserConfFilePath`"
          WriteUserConfFile;
        else
          USER_CONF_FILE=""
        fi

        #  Check INVOKED_AS first.  This allows a launcher to be a
        #  symlink to launch.sh but use its own conf file.
        local invokedDir=`dirname "${INVOKED_AS}"`
        local invokedProdName=`basename "${INVOKED_AS}"`
        local confFileName="${invokedProdName}.conf"
        local confFile="${invokedDir}/${confFileName}"
        if [ -f "${confFile}" ]
        then
            PRODUCT_NAME="${invokedProdName}"
            APP_CONF_DIR="${invokedDir}"
            APP_CONF_FILE="${confFile}"
            cd "${APP_CONF_DIR}"
            LaunchDir=$PWD
        else
            #  Check SCRIPT next.  This allows the user to make a
            #  symlink to the launcher script and use its conf file.
            local scriptDir=`dirname "${SCRIPT}"`
            PRODUCT_NAME=`basename "${SCRIPT}"`
            confFileName="${PRODUCT_NAME}.conf"
            confFile="${scriptDir}/${confFileName}"
            if [ -f "${confFile}" ]
            then
                APP_CONF_DIR="${scriptDir}"
                APP_CONF_FILE="${confFile}"
                cd "${APP_CONF_DIR}"
                LaunchDir=$PWD
            fi
        fi

        # Set tool specific user configuration file
        if [ "$USE_USER_CONF" = "0" ]
        then
          TOOL_SPECIFIC_USER_CONF_FILE="`GetUserConfDirPath`/${confFileName}"
          WriteToolSpecificUserConfFile;
        else
          TOOL_SPECIFIC_USER_CONF_FILE="";
        fi

        # Set platform configuration file.
        APP_UNAME_VALUE=`uname`
        APP_PLATFORM_CONF_FILE="${PRODUCT_NAME}-${APP_UNAME_VALUE}.conf"
        if [ -f "${APP_PLATFORM_CONF_FILE}" ]
        then
            APP_PLATFORM_CONF_FILE="${APP_CONF_DIR}/${PRODUCT_NAME}-${APP_UNAME_VALUE}.conf"
        fi

        # Prime the variables used for the Resolve function
        LAST_PWD_MADE_RELATIVE="$PWD"
        EchoIfVerbose "LAST_PWD_MADE_RELATIVE=$LAST_PWD_MADE_RELATIVE"
        LAST_RELATIVE_PWD=`computeRelativePath "$PWD" "$LaunchDir"`
        EchoIfVerbose "LAST_RELATIVE_PWD=$LAST_RELATIVE_PWD"
    }

    #:PreProcessArgs:
    {
      while [ $# -gt 0 ]
      do
        case $1 in
          -conf | -configure)
            if [ $# -gt 1 ]
            then
              #:SetConfFile:
              {
                case $2 in
                  /*)
                    # Absolute path
                    APP_CONF_FILE="$2"
                  ;;
                  *)
                    # Relative path
                    if [ "$STARTING_CWD" = "" ]
                    then
                      APP_CONF_FILE="$2";
                    else
                      APP_CONF_FILE="$STARTING_CWD/$2"
                    fi
                  ;;
                esac
              }
              shift
            fi
          ;;
          -help | --help)
          {
            ProductHandlesHelp
            HandlesHelp=$?
            if [ "$HandlesHelp" = "0" ]
            then
              ShowHelp
              exit 0;
            else
              break
            fi
          }
          ;;
          -verbose)
          {
            ProductHandlesVerbose
            HandlesVerbose=$?
            if [ "$HandlesVerbose" = "0" ]
            then
              SetVerbose
            else
              break
            fi
          }
          ;;
          --verbose)
            # Skip. Handled in PrePreProcessArgs
          ;;
          *)
            break
          ;;
        esac
        shift
      done
    }

    #:Startup:
    {
      APP_MAIN_CLASS="oracle.ide.boot.Launcher"
    }

    #:ReadSystemProxySettings:
    {
      DetectSystemHttpProxySetting
    }

    #:ReadConfig:
    {
      if [ -f "${APP_CONF_FILE}" ]
      then
        EchoIfVerbose "Reading configuration from: ${APP_CONF_FILE}"
        source "${APP_CONF_FILE}"
      else
        echo "Unable to find configuration file: ${APP_CONF_FILE}"
        exit 1
      fi

      if [ -f "${APP_PLATFORM_CONF_FILE}" ]
      then
        EchoIfVerbose "Reading platform specific configuration from: ${APP_PLATFORM_CONF_FILE}"
        source "${APP_PLATFORM_CONF_FILE}"
      fi

      if [ -f "${USER_CONF_FILE}" ]
      then
        EchoIfVerbose "Reading user configuration file from: ${USER_CONF_FILE}"
        IncludeConfFile "${USER_CONF_FILE}"
      fi

      if [ -f "${TOOL_SPECIFIC_USER_CONF_FILE}" ]
      then
        if [ "${TOOL_SPECIFIC_USER_CONF_FILE}" != "${USER_CONF_FILE}" ]
        then
          EchoIfVerbose "Reading tool specific override of user configuration file from: ${TOOL_SPECIFIC_USER_CONF_FILE}"
          IncludeConfFile "${TOOL_SPECIFIC_USER_CONF_FILE}"
        fi
      fi
    }

    # Check for debug mode set in the environment of jdevadf ade views
    # which should turn on Java asserts
    if [ "X$JDEV_DEBUG_MODE" = "Xtrue" ]
    then
      AddVMOption -ea
    fi

    #:ProcessArgs:
    {
      while [ $# -gt 0 ]
      do
        case $1 in
          --verbose)
            # Skip. Handled in PrePreProcessArgs
          ;;
          --*)
            NEWARG=`echo $1 | sed -e s/--//g`
            NEWOPD=`expr "$NEWARG" : '[^\=]*\=\(.*\)'`
            NEWARG=`expr "$NEWARG" : '\([^\=]*\)\=.*'`
            NEWARG=`echo $NEWARG | tr "[:upper:]" "[:lower:]"`
            case $NEWARG in
              setjavahome)                 NEWARG="SetJavaHome" ;;
              setjavavm)                   NEWARG="SetJavaVM" ;;
              addjavalibfile)              NEWARG="AddJavaLibFile" ;;
              addjava9libfile)             NEWARG="AddJava9LibFile" ;;
              addjava9orhigherlibfile)     NEWARG="AddJava9OrHigherLibFile" ;;
              setmainclass)                NEWARG="SetMainClass" ;;
              setskipj2sdkcheck)           NEWARG="SetSkipJ2SDKCheck" ;;
              addvmoption)                 NEWARG="AddVMOption" ;;
              addvmoptionjrockit)          NEWARG="AddVMOptionJRockit" ;;
              addvmoptionhotspot)          NEWARG="AddVMOptionHotspot" ;;
              addvmoptionhotspot8)         NEWARG="AddVMOptionHotspot8" ;;
              addvm8option)                NEWARG="AddVM8Option" ;;
              addvm9option)                NEWARG="AddVM9Option" ;;
              addvm9orhigheroption)        NEWARG="AddVM9OrHigherOption" ;;
              addlinuxvm9orhigheroption)   NEWARG="AddLinuxVM9OrHigherOption" ;;
              addmacvm9orhigheroption)     NEWARG="AddMacVM9OrHigherOption" ;;
              addsolarisvm9orhigheroption) NEWARG="AddSolarisVM9OrHigherOption" ;;
              add32vmoption)               NEWARG="Add32VMOption" ;;
              add64vmoption)               NEWARG="Add64VMOption" ;;
              addvmaddmodulesoption)       NEWARG="AddVMAddModulesOption" ;;
              *) NEWARG="" ;;
            esac
            if [ ! "$NEWARG" = "" ]
            then
              if [ "$NEWARG" = "SetJavaHome" ]
              then
                if [ "X$NEWOPD" = "X" ]
                then
                  echo "Error: incorrect use of --setjavahome command; syntax is --setjavahome=<base of jdk install>"
                  echo ""
                  exit 1
                fi
                local setJavaHomeDir="`Resolve $NEWOPD`"
                EchoIfVerbose "Checking that $setJavaHomeDir is a valid directory for --setjavahome command"
                if [ ! -d "$setJavaHomeDir" ]
                then
                  echo "Error: $NEWOPD, used with --setjavahome command, is not an existing directory"
                  echo ""
                  exit 1
                fi
              fi
              $NEWARG "$NEWOPD"
              EchoIfVerbose "* Added ${NEWARG}"
            else
              echo "Ignored unknown option $1"
            fi
          ;;
          -J*)
            NEWARG=`echo $1 | sed -e s/-J//g`
            AddVMOption ${NEWARG}
            EchoIfVerbose "* Added VM Option ${NEWARG}"
          ;;
          -debug)
            SetDebug
          ;;
          -uidebug)
            AddJavaLibFile ../lib/jdev-remote.jar
            SetDebug
            AddAppOption $1
            EchoIfVerbose "* Added Application Option $1"
          ;;
          -classic)
            NEWARG=`echo $1 | sed -e s/-//g`
            SetJavaVM ${NEWARG}
          ;;
          -hotspot)
            NEWARG=`echo $1 | sed -e s/-//g`
            SetJavaVM ${NEWARG}
          ;;
          -client)
            NEWARG=`echo $1 | sed -e s/-//g`
            SetJavaVM ${NEWARG}
          ;;
          -server)
            NEWARG=`echo $1 | sed -e s/-//g`
            SetJavaVM ${NEWARG}
          ;;
          -ojvm)
            NEWARG=`echo $1 | sed -e s/-//g`
            SetJavaVM ${NEWARG}
          ;;
          -conf | -configure)
            if [ $# -gt 1 ]
            then
              # Extra shift
              shift
            fi
          ;;
          -verbose)
          {
            ProductHandlesVerbose
            HandlesVerbose=$?
            if [ "$HandlesVerbose" != "0" ]
            then
              AddAppOption $1
              EchoIfVerbose "* Added Application Option $1"
            fi
          }
          ;;
          -nondebugmode)
          {
            AddVMOption -da
            AddAppOption $1
            EchoIfVerbose "* Added Application Option $1"
          }
          ;;
          -debugmode)
          {
            AddVMOption -ea
            AddAppOption $1
            EchoIfVerbose "* Added Application Option $1"
          }
          ;;
          -nouserconf)
            # Skip. Handled in PrePreProcessArgs
          ;;
          *)
            AddAppOption $1
            EchoIfVerbose "* Added Application Option $1"
          ;;
        esac
        shift
      done
    }

    # Pass the configuration pathname to the IDE
    AddVMOption -Dide.conf=\"${APP_CONF_FILE}\"

    # Pass the user configuration pathnames to the IDE
    AddVMOption -Duser.conf=\"${USER_CONF_FILE}\"
    AddVMOption -Dtool.user.conf=\"${TOOL_SPECIFIC_USER_CONF_FILE}\"

    # Pass the starting directory (before any chdir) to the IDE
    AddVMOption -Dide.startingcwd=\"${STARTING_CWD}\"

    CheckJDK
    CheckLibraryPath
    AppendVMSpecificOptions

    EchoIfVerbose "Working directory is `pwd`"
    EchoIfVerbose "Running Command: ${JAVA} ${APP_VM_OPTS[@]} ${APP_ENV_VARS} -classpath ${APP_CLASSPATH} ${APP_MAIN_CLASS} ${APP_APP_OPTS[@]}"


    for varname in ${APP_APP_OPTS[@]}; do
      if [[ "$varname" = '-nosplash' ||  "$varname" = '-nonag' ]]
      then
        for (( i = 0; i < ${#APP_VM_OPTS[@]}; i++ )); do
          if [ "${APP_VM_OPTS[$i]}" = '-splash:splash.gif' ]
          then
            unset APP_VM_OPTS[$i]
          fi
        done
      fi
    done

    local exitCode=245
    while [ "$exitCode" = "245" ]
    do
      ${JAVA} "${APP_VM_OPTS[@]}" ${APP_ENV_VARS} -classpath ${APP_CLASSPATH} ${APP_MAIN_CLASS} "${APP_APP_OPTS[@]}"
      exitCode=$?
      ProductCanRestart
      CanRestart=$?
      if [ "$CanRestart" = "0" ]
      then
        break
      fi
    done

    return $exitCode
}

# The following HTTP proxy-related code taken from NetBeans nbexec script.
DetectSystemHttpProxySetting()
{

    unset http_proxy_tmp

    if [ `uname` = Darwin ] ; then
	detect_macosx_proxy
    else
	if [ "$KDE_FULL_SESSION" = "true" ] ; then
            detect_kde_proxy
	else
            if [ ! -z "$GNOME_DESKTOP_SESSION_ID" ] ; then
        	detect_gnome_proxy
            fi
	fi
    fi

    # fall back to the environment-defined http_proxy if nothing found so far
    if [ -z "$http_proxy_tmp" ]; then
	http_proxy_tmp=$http_proxy
    fi

    if [ ! -z "$http_proxy_tmp" ] ; then
    #	jargs="-Dnetbeans.system_http_proxy=\"$http_proxy_tmp\" -Dnetbeans.system_http_non_proxy_hosts=\"$http_non_proxy_hosts\" $jargs"
	    AddVMOption -Djdeveloper.system_http_proxy=$http_proxy_tmp
	    AddVMOption -Djdeveloper.system_http_non_proxy_hosts=$http_non_proxy_hosts
    fi

    if [ ! -z "$socks_proxy_tmp" ] ; then
    #	jargs="-Dnetbeans.system_socks_proxy=\"$socks_proxy_tmp\" $jargs"
	    AddVMOption -Djdeveloper.system_socks_proxy=$socks_proxy_tmp
    fi

}

detect_system_proxy () {
    if [ ! -z "$http_proxy" ]; then
        http_proxy_tmp=$http_proxy
    fi
    return 0
}

detect_gnome_proxy () {
    gconftool=/usr/bin/gconftool-2
    if [ -x  $gconftool ] ; then
        proxy_mode=`$gconftool --get /system/proxy/mode 2>/dev/null`
        if [ "$proxy_mode" = "manual" ] ; then
            http_proxy_host=`$gconftool --get /system/http_proxy/host 2>/dev/null`
            http_proxy_port=`$gconftool --get /system/http_proxy/port 2>/dev/null`
            http_proxy_tmp=$http_proxy_host:$http_proxy_port
            http_non_proxy_hosts=`$gconftool --get /system/http_proxy/ignore_hosts 2>/dev/null`
            if [ $? ] ; then
                http_non_proxy_hosts=`echo $http_non_proxy_hosts | /bin/sed 's/\]//'`
            fi
            socks_proxy_host=`$gconftool --get /system/proxy/socks_host 2>/dev/null`
            socks_proxy_port=`$gconftool --get /system/proxy/socks_port 2>/dev/null`
            socks_proxy_tmp=$socks_proxy_host:$socks_proxy_port

            return 0
        else
            if [ "$proxy_mode" = "none" ] ; then
                detect_system_proxy
                if [ -z "$http_proxy_tmp" ]; then
                    http_proxy_tmp="DIRECT"
                fi
                return 0
            else
                if [ "$proxy_mode" = "auto" ] ; then
                    detect_system_proxy
                    pac_file=`$gconftool --get /system/proxy/autoconfig_url 2>/dev/null`
                    if [ ! -z "$pac_file" ]; then
                        http_proxy_tmp="PAC "$pac_file
                    fi
                    return 0
                fi
            fi
        fi
    fi
    return 1
}

detect_kde_proxy () {
    kioslaverc="${HOME}/.kde/share/config/kioslaverc"
    if [ -f $kioslaverc ] ; then
        if /bin/grep 'ProxyType=1' "$kioslaverc" >/dev/null 2>&1; then
            http_proxy_tmp=`/bin/grep 'httpProxy=http://' "$kioslaverc"`
            if [ $? ] ; then
                http_proxy_tmp=`echo $http_proxy_tmp | /bin/sed 's/httpProxy=http:\/\///'`
                return 0
            fi
            http_non_proxy_hosts=`/bin/grep 'NoProxyFor=' "$kioslaverc"`
            if [ $? ] ; then
                http_non_proxy_hosts=`echo $http_non_proxy_hosts | /bin/sed 's/NoProxyFor=//'`
            fi
        else
            if /bin/grep 'ProxyType=0' "$kioslaverc" >/dev/null 2>&1; then
                detect_system_proxy
                if [ -z "$http_proxy_tmp" ]; then
                    http_proxy_tmp="DIRECT"
                fi
                return 0
            else
                if /bin/grep 'ProxyType=2' "$kioslaverc" >/dev/null 2>&1; then
                    pac_file=`grep "Proxy Config Script=" $kioslaverc  | cut -f 2 -d =`
                    http_proxy_tmp="PAC "$pac_file
                    return 0
                fi
            fi
        fi
    fi
    return 1
}

detect_macosx_proxy () {
    if [ ! -x /usr/sbin/scutil ] ; then
	return 1
    fi

    scutil_out=/tmp/nb-proxy-detection.$$
    cat <<EOF | /usr/sbin/scutil > ${scutil_out}
open
show State:/Network/Global/Proxies
close
EOF

    if /usr/bin/grep "ProxyAuto.*: *1" ${scutil_out} >/dev/null 2>&1; then
        if  /usr/bin/grep "ProxyAutoConfigEnable.*: *1" ${scutil_out} >/dev/null 2>&1; then
            http_proxy_tmp="PAC `/usr/bin/grep ProxyAutoConfigURLString ${scutil_out} | /usr/bin/awk 'END{print $3}'`"
            rm ${scutil_out}
            return 0
        fi

        rm ${scutil_out}
        return 1
    fi

    if /usr/bin/grep "HTTPEnable *: *1" ${scutil_out} >/dev/null 2>&1; then
	http_proxy_host=`/usr/bin/grep HTTPProxy ${scutil_out} | /usr/bin/awk 'END{print $3}'`
	http_proxy_port=`/usr/bin/grep HTTPPort ${scutil_out} | /usr/bin/awk 'END{print $3} '`
        http_proxy_tmp=$http_proxy_host:$http_proxy_port
        rm ${scutil_out}
        return 0
    fi

    http_proxy_tmp="DIRECT"
    rm ${scutil_out}
    return 0
}
