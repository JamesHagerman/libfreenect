#!/bin/sh

LIBUSB_INCLUDE=-I/usr/include/libusb-1.0
LIBUSB_LIBRARY=-lusb-1.0

LIBFREENET_INCLUDE=-I../../include/
#LIBFREENET_LIBRARY=../../build/lib/libfreenect.a

# -- try to use installed as fallback
#if [ -z ${LIBFREENET_INCLUDE} ]; then LIBFREENET_INCLUDE="/usr/include/libfreenect/"; fi
if [ -z ${LIBFREENET_LIBRARY} ]; then LIBFREENET_LIBRARY="/usr/local/lib/libfreenect.a"; fi


#-- if jdk home is not set try ubuntu default
if [ -z ${JDK_HOME} ]; then JDK_HOME="/Library/Java/JavaVirtualMachines/1.6.0_37-b06-434.jdk/Contents/Home"; fi

JNI_SRC_DIR=OpenKinectJNI
#JAVA_SRC_DIR=src
JAVA_SRC_DIR=OpenKinect/src

CORE_SRC_DIR=/Users/jhagerman/Desktop/my_root/development/my_git_root/libfreenect/wrappers/java_processing/processing/KinectProcessing/lib/base/core/core.jar
JNA_SRC_DIR=/Users/jhagerman/Desktop/my_root/development/java/jna-4.0.0.jar

mkdir -p dist/javadoc

g++ -m64 -shared -fPIC -Wall -o dist/libOpenKinect.so ${JNI_SRC_DIR}/org_openkinect_Context.cpp OpenKinectJNI/org_openkinect_Device.cpp ${LIBUSB_INCLUDE} ${LIBUSB_LIBRARY} ${LIBFREENET_INCLUDE} ${LIBFREENET_LIBRARY} -I${JDK_HOME}/include/ -I${JDK_HOME}/include/linux/ -L${JDK_HOME}/lib/
#g++ -m32 -shared -fPIC -Wall -o dist/libOpenKinect.so ${JNI_SRC_DIR}/org_openkinect_Context.cpp OpenKinectJNI/org_openkinect_Device.cpp ${LIBUSB_INCLUDE} ${LIBUSB_LIBRARY} ${LIBFREENET_INCLUDE} ${LIBFREENET_LIBRARY} -I${JDK_HOME}/include/ -I${JDK_HOME}/include/linux/ -L${JDK_HOME}/lib/

mkdir -p build

#javac -d build -cp ${JNA_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/main/java/org/openkinect/freenect/*.java
#javadoc -d dist/javadoc/ -classpath ${JNA_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/main/java/org/openkinect/freenect/*.java

#javac -d build -cp ${JNA_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/org/openkinect/*.java
#javadoc -d dist/javadoc/ -classpath ${JNA_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/org/openkinect/*.java

javac -d build -cp ${JNA_SRC_DIR}:${CORE_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/org/openkinect/*.java ${JAVA_SRC_DIR}/org/openkinect/processing/*.java
javadoc -d dist/javadoc/ -classpath ${JNA_SRC_DIR}:${CORE_SRC_DIR}:. -sourcepath ${JAVA_SRC_DIR} ${JAVA_SRC_DIR}/org/openkinect/*.java


jar cvf dist/Freenect.jar -C build .

rm -R build
