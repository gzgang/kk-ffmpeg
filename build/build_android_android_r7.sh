#!/bin/bash

export NDK=$HOME/Documents/ffmpegStudy/source/android-ndk-r7
export TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.4.3/prebuilt/darwin-x86

#if [ ! -d $TOOLCHAIN ]; then
#    $NDK/build/tools/make-standalone-toolchain.sh \
#        --platform=android-8 \
#        --install-dir=$TOOLCHAIN
#fi

export PATH=$TOOLCHAIN/bin:$PATH
export SYSROOT=$NDK/platforms/android-9/arch-arm/
export CC="arm-linux-androideabi-gcc --sysroot $SYSROOT"
export CXX=arm-linux-androideabi-g++

function build_one
{
./configure --target-os=linux \
  --prefix=$PREFIX \
  --enable-cross-compile \
  --extra-libs="-lgcc" \
  --arch=arm \
  --cross-prefix=arm-linux-androideabi- \
  --sysroot=$SYSROOT \
  --extra-cflags="-O0 -g3 -fpic -DANDROID -D__ANDROID__ -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums  -fno-strict-aliasing -finline-limit=300 $OPTIMIZE_CFLAGS -I$INC" \
  --disable-shared \
  --enable-static \
  --extra-ldflags="-L$SYSROOT/usr/lib -nostdlib -lc -lm -lz -ldl -llog -L$LIB" \
  --enable-swscale \
  --disable-ffplay \
  --disable-ffmpeg \
  --disable-ffprobe \
  --disable-ffserver \
  --enable-indevs \
  --enable-libx264 \
  --disable-avdevice \
  --disable-postproc \
  --disable-doc \
  --enable-optimizations \
  --enable-avresample \
  --enable-swscale \
  --enable-hwaccels \
  --enable-swresample \
  --enable-small \
  --enable-avfilter \
  --enable-gpl \
  --enable-yasm \
  --enable-network \
  --enable-asm \
  --enable-inline-asm \
  --enable-debug \
  --disable-devices \
  --enable-pic \
  --enable-filters \
  --disable-protocols --enable-protocol=file,http,mem \
  --disable-bsfs --enable-bsf=h264_mp4toannexb,h264_changesps \
  --disable-muxers --enable-muxer=mpegts,flv,gif,image2,mjpeg,aac,avi,mov,mp3,mp4,adts,h264,mpegts,matroska,matroska_audio \
  --disable-demuxers --enable-demuxer=hls,mpegts,h264,mov,m4v,mpegts,aac,ac3,gif,concat,image2,avi,mp3,matroska,mgsts,mpegvideo \
  --disable-encoders --enable-encoder=mjpeg,jpeg2000,gif,libx264,aac,ac3,png,mpeg4,libxavs,libfdk_aac \
  --disable-decoders --enable-decoder=h264,aac,aac_latm,ac3,mpeg4,gif,mp3,flac,mjpeg,png,h264_mediacodec,mpeg4_mediacodec \
  --enable-parsers --disable-parser=pnm,adx,cavsvideo,mlp,dnxhd,h261,dirac,hevc \
  $ADDITIONAL_CONFIGURE_FLAG

make clean
make -j 4
make install

arm-linux-androideabi-ar d libavcodec/libavcodec.a inverse.o

arm-linux-androideabi-ld -rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -soname $OUTPUT_SO_NAME -shared -nostdlib -z noexecstack -Bsymbolic --whole-archive --no-undefined -o $PREFIX/$OUTPUT_SO_NAME \
$LIB/libx264.a \
libavcodec/libavcodec.a \
libpostproc/libpostproc.a \
libavresample/libavresample.a \
libavfilter/libavfilter.a \
libswresample/libswresample.a \
libavformat/libavformat.a \
libavutil/libavutil.a \
libswscale/libswscale.a \
-lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
$TOOLCHAIN/lib/gcc/arm-linux-androideabi/4.4.3/libgcc.a

arm-linux-androideabi-strip --strip-unneeded $PREFIX/$OUTPUT_SO_NAME

#cp $PREFIX/libffmpeg_acos.so ../../lib/Android/ffmpeg/armeabi
#cp -a $PREFIX/include/* ../../include/ffmpeg/

#
echo "----------------------------------------------"
echo "Android $CPU builds finished"
echo "----------------------------------------------"
}

#arm v6
#CPU=armv6
#OPTIMIZE_CFLAGS="-marm -march=$CPU"
#PREFIX=./android/$CPU 
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v7vfpv3
#CPU=armv7-a
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
#PREFIX=./android/$CPU 
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v7vfp
#CPU=armv7-a
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU "
#PREFIX=./android/$CPU-vfp
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v7n
CPU=armv7-a
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8"
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU"
#PREFIX=$(pwd)/lib/ffmpeg/$CPU
ADDITIONAL_CONFIGURE_FLAG=--enable-neon
#ICONV_INC_PATH=../../include/iconv
#ICONV_LIB_PATH="../../lib/Android/iconv/armeabi/libiconv.a"
#HLS_CACHE_INC_PATH=/Users/lite/Documents/work/acos_vplayer_native/localserver_hls_cache_cs/common
#HLS_CACHE_LIB_PATH="/Users/lite/Documents/work/acos_vplayer_native/localserver_hls_cache_cs/android/libs/armeabi/"

# x264库所在的位置，ffmpeg 需要链接 x264
LIB_DIR=$(pwd)/lib;

# ffmpeg编译输出前缀
PREFIX=$LIB_DIR/ffmpeg/$CPU
echo "out dir: $PREFIX"
# x264的头文件地址
INC="$LIB_DIR/x264/$CPU/include"
# x264的静态库地址
LIB="$LIB_DIR/x264/$CPU/lib"
# 输出调试
echo "include dir: $INC"
echo "lib dir: $LIB"

OUTPUT_SO_NAME=libffmpeg_ugc.so

cd ../ffmpeg

build_one

#arm v6+vfp
#CPU=armv6
#OPTIMIZE_CFLAGS="-DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU"
#PREFIX=./android/${CPU}_vfp 
#ADDITIONAL_CONFIGURE_FLAG=

