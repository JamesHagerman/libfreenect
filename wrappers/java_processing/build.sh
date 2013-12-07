#!/bin/sh

LIBUSB_INCLUDE=-I/usr/include/libusb-1.0
LIBUSB_LIBRARY=-lusb-1.0

LIBFREENET_INCLUDE=-I../../include/

# This library file is the ACTUAL libfreenect library. It is built using CMake and make. It is required to build the
# Processing Kinect library by David Shiffman:
# To build this library:
# cd libfreenect; mkdir build; cd build; cmake ..; make; sudo make install;
#
# Actually, that make install isn't really needed because the next line references the compiled .a file directly:
LIBFREENET_LIBRARY=../../build/lib/libfreenect.a

# -- try to use installed as fallback
# This is the install location on Linux (as far as I am aware):
#if [ -z ${LIBFREENET_INCLUDE} ]; then LIBFREENET_INCLUDE="/usr/include/libfreenect/"; fi

# This is the normal install location on OS X:
if [ -z ${LIBFREENET_LIBRARY} ]; then LIBFREENET_LIBRARY="/usr/local/lib/libfreenect.a"; fi


#-- if jdk home is not set try ubuntu default
# Yeah, actually, no. We're just gonna fucking set it ourselves because Java on OS X is a bitch. But, sure, if you've
# defined JDK_HOME yourself, I guess we can use your version instead.
if [ -z ${JDK_HOME} ]; then JDK_HOME="/Library/Java/JavaVirtualMachines/1.6.0_37-b06-434.jdk/Contents/Home"; fi


# This is the old location of the Processing library source tree:
#JAVA_SRC_DIR=src

# ... But it's not there anymore. OpenKinectJNI and the new location for the source tree had to be mangled a bit:
JNI_SRC_DIR=OpenKinectJNI
JAVA_SRC_DIR=OpenKinect/src

# Processing libraries need the Processing core.jar. Here it is:
CORE_SRC_DIR=/Users/jhagerman/Desktop/my_root/development/my_git_root/libfreenect_mine/libfreenect/wrappers/java_processing/processing/KinectProcessing/lib/base/core/core.jar

# And this library uses JNA... which had to be downloaded on it's own too... and is here:
JNA_SRC_DIR=/Users/jhagerman/Desktop/my_root/development/java/jna-4.0.0.jar

# We don't _really_ need javadocs but whatever:
mkdir -p dist/javadoc

# This will build the lowlevel shared object file that the Kinect Processing library needs to interface with the hardware:
#           output: libOpenKinect.so
#         location: dist/libOpenKinect.so
# correct filename: libkinect.jnilib
#g++ -m64 -shared -fPIC -Wall -o dist/libOpenKinect.so ${JNI_SRC_DIR}/org_openkinect_Context.cpp OpenKinectJNI/org_openkinect_Device.cpp ${LIBUSB_INCLUDE} ${LIBUSB_LIBRARY} ${LIBFREENET_INCLUDE} ${LIBFREENET_LIBRARY} -I${JDK_HOME}/include/ -I${JDK_HOME}/include/linux/ -L${JDK_HOME}/lib/
#g++ -m32 -m64 -shared -fPIC -Wall -o dist/libOpenKinect.so ${JNI_SRC_DIR}/org_openkinect_Context.cpp OpenKinectJNI/org_openkinect_Device.cpp ${LIBUSB_INCLUDE} ${LIBUSB_LIBRARY} ${LIBFREENET_INCLUDE} ${LIBFREENET_LIBRARY} -I${JDK_HOME}/include/ -I${JDK_HOME}/include/linux/ -L${JDK_HOME}/lib/
g++ -arch x86_64 -arch i386  -shared -fPIC -Wall -o dist/libOpenKinect.so ${JNI_SRC_DIR}/org_openkinect_Context.cpp OpenKinectJNI/org_openkinect_Device.cpp ${LIBUSB_INCLUDE} ${LIBUSB_LIBRARY} ${LIBFREENET_INCLUDE} ${LIBFREENET_LIBRARY} -I${JDK_HOME}/include/ -I${JDK_HOME}/include/linux/ -L${JDK_HOME}/lib/


# All of the code below here is building the actual Java part of the library.
# It makes a directory named build...
mkdir -p build

#javac -d build -cp ${JNA_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/main/java/org/openkinect/freenect/*.java
#javadoc -d dist/javadoc/ -classpath ${JNA_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/main/java/org/openkinect/freenect/*.java

#javac -d build -cp ${JNA_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/org/openkinect/*.java
#javadoc -d dist/javadoc/ -classpath ${JNA_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/org/openkinect/*.java


# ... Then compiles a bunch of source code into that directory...
javac -d build -cp ${JNA_SRC_DIR}:${CORE_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/org/openkinect/*.java ${JAVA_SRC_DIR}/org/openkinect/processing/*.java
javadoc -d dist/javadoc/ -classpath ${JNA_SRC_DIR}:${CORE_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/org/openkinect/*.java


# ... Then plops all that code into a .jar file named Freenect.jar:
jar cvf dist/Freenect.jar -C build .

# ... Then it removes the build directory that all that code was compiled into. It's not needed once all the code is jar'd
rm -R build
