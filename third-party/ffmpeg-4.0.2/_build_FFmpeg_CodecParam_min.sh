#!/bin/bash

echo -e "\033[31m========================================================================\033[0m"
echo -e "\033[31m************    Build    FFmpeg    under    mode:    min    ************\033[0m"
echo -e "\033[31m========================================================================\033[0m"
FFmpeg_CodecParam='
	--disable-doc
	--disable-ffmpeg
	--disable-ffprobe
	--disable-ffplay
	--disable-avfilter
	--disable-avdevice
	--disable-muxers
	--disable-filters
	--disable-bsfs
	--disable-devices
	--disable-encoders
	--disable-decoders
	--disable-demuxers
	--disable-parsers
	--disable-protocols
	--enable-decoder=mpeg1video
	--enable-decoder=mpeg2video
	--enable-decoder=mpegvideo
	--enable-decoder=h264
	--enable-decoder=aac
	--enable-decoder=mp3
	--enable-decoder=ass
	--enable-demuxer=aac
	--enable-demuxer=flv
	--enable-demuxer=h264
	--enable-demuxer=hls
	--enable-demuxer=mpegts
	--enable-demuxer=mpegvideo
	--enable-demuxer=m4v
	--enable-demuxer=mov
	--enable-parser=aac
	--enable-parser=mpegaudio
	--enable-parser=h264
	--enable-protocol=applehttp
	--enable-protocol=hls
	--enable-protocol=http
	--enable-protocol=httpproxy
	--enable-protocol=https
	--enable-protocol=file
    --enable-bsf=h264_mp4toannexb
    --enable-bsf=aac_adtstoasc
    --disable-stripping
	--enable-pthreads
	--enable-static
	--enable-pic
	--enable-runtime-cpudetect
    --enable-decoder=hevc
    --enable-demuxer=hevc
    --enable-parser=hevc
    --enable-decoder=srt
    --enable-decoder=ssa
    --enable-decoder=subrip
    --enable-demuxer=srt
    --enable-demuxer=srt_external
'

FFMPEG_OUTPUT_LIBS=" \
	libavcodec/libavcodec.a \
	libswresample/libswresample.a \
	libavformat/libavformat.a \
	libavutil/libavutil.a \
	libswscale/libswscale.a \
	"

EXTERNAL_LIBS_X86=""
EXTERNAL_LIBS_GCC=""
EXTERNAL_LIBS_NEON=""
