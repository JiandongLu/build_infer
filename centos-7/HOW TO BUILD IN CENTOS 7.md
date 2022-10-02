# How to build Infer in CENTOS 7 

Here we will illustrate how to build infer 1.1.0 in CENTOS 7
The operating system I used to test is CENTOS 7.6

facebook infer teams recommands we to use ubuntu/Docker to build it.
the Dockerfile to build it is : $INFER_SOURCE/docker/master/Dockerfile
so if you encouter some problems while build infer 1.1.0, read the doc.  

hardwares recommanded are:
4 CPU or 8 CPU
RAM: 32GB
the root file system : 80GB


## Step 1: prepare the environment

### 1.1 install devtoolset 
```
yum install -y centos-release-scl
yum install -y devtoolset-11
scl enable devtoolset-11 -- bash
source /opt/rh/devtoolset-11/enable
```

**BE CAREFUL**

	before execute gcc, use this command to enable gcc-11 	
	scl enable devtoolset-11 -- bash
	
### 1.2 install cmake 3.24
**BE CAREFUL**

CMake 3.4.3 or higher is required

#### 1.2.1 download source code:
source code url:
https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2.tar.gz

#### 1.2.2 uncompress it
#### 1.2.3 if you do not have openssl
mofify $CMAKE_SOURCE/CMakeLists.txt
add the bellow line to this file:
set(CMAKE_USE_OPENSSL OFF)

#### 1.2.4 build and install
./bootstrap && make && sudo make install

### 1.3 install Python 3.7

#### 1.3.1 prepare env
```
yum -y install -y lsb
yum -y install -y libXScrnSaver
yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel libffi-devel  
```

#### 1.3.2 download source code
```
wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
```

#### 1.3.3 uncompress
```
tar -zxvf Python-3.7.0.tgz
```

#### 1.3.4 configure
```
./configure --with-ssl
```
or 
```
./configure --enable-optimizations --with-ssl
```

#### 1.3.5 build and install 
```
make && make install 
```

#### 1.3.6 make some links
```
ln -s /usr/local/bin/python3 /usr/bin/python3
ln -s /usr/local/bin/pip3 /usr/bin/pip3
```

#### 1.3.7 upgrade pip3 
```
pip3 install --upgrade pip
```

### 1.4 others
```
yum install -y perl-Digest-SHA
yum install -y glibc-static libstdc++-static
```

## Step 2: install prerequisites
```
yum install -y autoconf automake bubblewrap bzip2 make git curl unzip
yum install -y patch 

#deb: patchelf 
yum install -y epel-release
yum install -y patchelf

#deb: libgmp-dev libmpfr-dev 
yum install -y gmp-devel.x86_64 mpfr-devel.x86_64

#deb: libsqlite3-dev 
yum install -y sqlite-devel.x86_64 

#deb: openjdk-11-jdk-headless 
yum install -y java-11-openjdk-devel.x86_64

#zlib1g-dev 
yum install -y zlib-devel.x86_64
```

## Step 3: fetch and setup opam
```
curl -sL https://github.com/ocaml/opam/releases/download/2.0.6/opam-2.0.6-x86_64-linux > /usr/bin/opam && chmod +x /usr/bin/opam
opam init --reinit --bare --disable-sandboxing --yes --auto-setup
```

## Step 4: fetch infer 1.1.0
```
wget https://github.com/facebook/infer/archive/refs/tags/v1.1.0.tar.gz
tar -zxvf infer-1.1.0.tar.gz
```

## Step 5: fetch clang and llvm
```
cd $INFER_DIR && ./facebook-clang-plugins/clang/src/prepare_clang_src.sh
```

## Step 6: modify the source codes

### 6.1 select CPU

open this file:
$INFER_DIR/facebook-clang-plugins/clang/setup.sh

find the variable CMAKE_ARGS 
and modify it

### 6.2 benchmark_register.h

$INFER_DIR/facebook-clang-plugins/clang/src/download/llvm-project/llvm/utils/benchmark/src/benchmark_register.h
add an extra include line:

```
 #include <limits>
```

### 6.3 merge_archives.py

$INFER_DIR/facebook-clang-plugins/clang/src/download/llvm-project/libcxx/utils/merge_archives.py
There are two overloaded functions with the same name execute_command
modify the declaration of the first function as:
```
def execute_command(cmd, cwd):
```

### 6.3 FileUtils.cpp

$INFER_DIR/facebook-clang-plugins/libtooling/FileUtils.cpp

in the function **makeAbsolutePath**，replace this line 
```
const std::string &element(llvm::sys::path::filename(path));
```
with 
```
const std::string &element(llvm::sys::path::filename(path).str());
```

## Step 7: setup clang
```
cd $INFER_DIR && eval $(opam env) && ./autogen.sh && ./configure && ./facebook-clang-plugins/clang/setup.sh 
```

## Setp 8: build infer
```
#cd $INFER_DIR &&  make install-with-libs BUILD_MODE=opt PATCHELF=patchelf DESTDIR="/infer-release" libdir_relative_to_bindir="../lib" 
```