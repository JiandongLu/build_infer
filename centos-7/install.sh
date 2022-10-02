#!/bin/sh

#$ ./bootstrap && make && sudo make install

function install_devtoolset()
{
    yum install -y centos-release-scl
    yum install -y devtoolset-11
}

function install_prerequisites()
{
    INSTALL_OPT="-y"
    #apt-get install --yes --no-install-recommends \
    yum install $INSTALL_OPT autoconf automake bubblewrap bzip2 make git curl unzip

    yum install $INSTALL_OPT patch 

    #deb: patchelf 
    yum install $INSTALL_OPT epel-release
    yum install $INSTALL_OPT patchelf

    #libc6-dev 

    #libgmp-dev libmpfr-dev 
    yum install $INSTALL_OPT gmp-devel.x86_64 mpfr-devel.x86_64

    #libsqlite3-dev 
    yum install $INSTALL_OPT sqlite-devel.x86_64 

    #openjdk-11-jdk-headless 
    yum install $INSTALL_OPT java-11-openjdk-devel.x86_64

    #deb: pkg-config 
    #deb: xz-utils 

    #zlib1g-dev 
    yum install $INSTALL_OPT zlib-devel.x86_64

    ###########
    yum install $INSTALL_OPT perl-Digest-SHA

    yum install $INSTALL_OPT glibc-static libstdc++-static
}

function check_env()
{
    TMP=`rpm -qa | grep devtoolset`
    if [ "$TMP" == "" ]; then
        echo "devtoolset has not installed now"
        echo "install devtoolset first"
        exit 2
    else
        echo "devtoolset has been installed now"
    fi

    TMP=`which cmake`
    if [ "$TMP" == "" ]; then
        echo "cmake has not installed now"
        echo "install cmake first"
        exit 3
    else
        echo "cmake exists"
    fi

    TMP=`which python3`
    if [ "$TMP" == "" ]; then
        echo "python3 has not installed now"
        echo "install python3 first"
        echo "you'd better install python3.7"
        exit 4
    else
        echo "python3 has been installed now"
    fi

    TMP=`which patchelf`
    if [ "$TMP" == "" ]; then
        echo "patchelf has not installed now"
        echo "install patchelf first"
        echo "you'd better install patchelf"
        exit 5
    else
        echo "patchelf has been installed now"
    fi
}


#1. prepare env

#scl enable devtoolset-11 -- bash
#install_devtoolset

#cd cmake-3.24.2 && ./bootstrap && make && sudo make install

#check_env

#2
#install_prerequisites

#3
#curl -sL https://github.com/ocaml/opam/releases/download/2.0.6/opam-2.0.6-x86_64-linux > /usr/bin/opam && chmod +x /usr/bin/opam
#opam init --reinit --bare --disable-sandboxing --yes --auto-setup

#
INFER_DIR="/root/infer-1.1.0"
if [ -d $INFER_DIR ]; then
    :
else
    echo "$INFER_DIR does not exist"
    exit 6
fi
#4
#cd $INFER_DIR && ./build-infer.sh --only-setup-opam

#5
#cd $INFER_DIR && ./facebook-clang-plugins/clang/src/prepare_clang_src.sh

#6
#modify the source codes

#7
#cd $INFER_DIR && eval $(opam env) && ./autogen.sh && ./configure && ./facebook-clang-plugins/clang/setup.sh 

#echo "`date` setup.sh has completed" >> output.txt

#8
#cd $INFER_DIR &&  make install-with-libs BUILD_MODE=opt PATCHELF=patchelf DESTDIR="/infer-release" libdir_relative_to_bindir="../lib" 
