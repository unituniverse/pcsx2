#-------------------------------------------------------------------------------
#                              Dependency message print
#-------------------------------------------------------------------------------
set(msg_dep_common_libs "check these libraries -> wxWidgets (>=3.0), aio")
set(msg_dep_pcsx2       "check these libraries -> wxWidgets (>=3.0), gtk2, zlib (>=1.2.4), pcsx2 common libs")
set(msg_dep_cdvdgiga    "check these libraries -> gtk2, libudev")
set(msg_dep_zerogs      "check these libraries -> glew, opengl, X11, nvidia-cg-toolkit (>=2.1)")
set(msg_dep_gsdx        "check these libraries -> opengl, png (>=1.2), zlib (>=1.2.4), X11, liblzma")
set(msg_dep_onepad      "check these libraries -> sdl2, X11, gtk2")
set(msg_dep_spu2x       "check these libraries -> soundtouch (>=1.5), alsa, portaudio (optional, >=1.9), sdl (>=1.2), pcsx2 common libs")
set(msg_dep_zerospu2    "check these libraries -> soundtouch (>=1.5), alsa")
set(msg_dep_dev         "check these libraries -> gtk2, pcap, libxml2")
if(GLSL_API)
	set(msg_dep_zzogl       "check these libraries -> glew, jpeg (>=6.2), opengl, X11, pcsx2 common libs")
else(GLSL_API)
	set(msg_dep_zzogl       "check these libraries -> glew, jpeg (>=6.2), opengl, X11, nvidia-cg-toolkit (>=2.1), pcsx2 common libs")
endif()

macro(print_dep str dep)
    if (PACKAGE_MODE)
        message(FATAL_ERROR "${str}:${dep}")
    else()
        message(STATUS "${str}:${dep}")
    endif()
endmacro(print_dep)

#-------------------------------------------------------------------------------
#								Pcsx2 core & common libs
#-------------------------------------------------------------------------------
# Check for additional dependencies.
# If all dependencies are available, including OS, build it
#-------------------------------------------------------------------------------
if (GTK2_FOUND OR GTK3_FOUND)
    set(GTKn_FOUND TRUE)
elseif(APPLE) # Not we have but that we don't change all if(gtkn) entries
    set(GTKn_FOUND TRUE)
else()
    set(GTKn_FOUND FALSE)
endif()

if(SDL_FOUND OR SDL2_FOUND)
    set(SDLn_FOUND TRUE)
else()
    set(SDLn_FOUND FALSE)
endif()

#---------------------------------------
#			Common libs
# requires: -wx
#---------------------------------------
if(wxWidgets_FOUND)
    set(common_libs TRUE)
elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/common/src")
    set(common_libs FALSE)
else()
    set(common_libs FALSE)
    print_dep("Skip build of common libraries: missing dependencies" "${msg_dep_common_libs}")
endif()

#---------------------------------------
#			Pcsx2 core
# requires: -wx
#           -gtk2 (linux)
#           -zlib
#           -common_libs
#           -aio
#---------------------------------------
# Common dependancy
if(wxWidgets_FOUND AND ZLIB_FOUND AND common_libs AND NOT (Linux AND NOT AIO_FOUND))
    set(pcsx2_core TRUE)
elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/pcsx2")
    set(pcsx2_core FALSE)
else()
    set(pcsx2_core FALSE)
    print_dep("Skip build of pcsx2 core: missing dependencies" "${msg_dep_pcsx2}")
endif()
# Linux, BSD, use gtk2, but not OSX
if(UNIX AND pcsx2_core AND NOT GTKn_FOUND AND NOT APPLE)
    set(pcsx2_core FALSE)
    print_dep("Skip build of pcsx2 core: missing dependencies" "${msg_dep_pcsx2}")
endif()


#-------------------------------------------------------------------------------
#								Plugins
#-------------------------------------------------------------------------------
# Check all plugins for additional dependencies.
# If all dependencies of a plugin are available, including OS, the plugin will
# be build.
#-------------------------------------------------------------------------------

#---------------------------------------
#			CDVDnull
#---------------------------------------
if(GTKn_FOUND)
    set(CDVDnull TRUE)
endif()
#---------------------------------------

#---------------------------------------
#			cdvdGigaherz
#---------------------------------------
if(NOT EXISTS "${CMAKE_SOURCE_DIR}/plugins/cdvdGigaherz" OR NOT Linux)
    set(cdvdGigaherz FALSE)
elseif(Linux AND GTKn_FOUND AND LIBUDEV_FOUND)
    set(cdvdGigaherz TRUE)
else()
    set(cdvdGigaherz FALSE)
    print_dep("Skip build of cdvdGigaherz: missing dependencies" "${msg_dep_cdvdgiga}")
endif()
#---------------------------------------

#---------------------------------------
#			dev9null
#---------------------------------------
if(GTKn_FOUND)
    set(dev9null TRUE)
endif()

#---------------------------------------
#			dev9ghzdrk
#---------------------------------------
if(NOT DISABLE_DEV9GHZDRK)
if(GTKn_FOUND AND PCAP_FOUND AND LIBXML2_FOUND)
    set(dev9ghzdrk TRUE)
    list(APPEND CMAKE_MODULE_PATH
        ${CMAKE_MODULE_PATH}/macros)
    include(GlibCompileResourcesSupport) 
else()
    set(dev9ghzdrk FALSE)
    print_dep("Skip build of dev9ghzdrk: missing dependencies" "${msg_dep_dev}")
endif()
endif()
#---------------------------------------

#---------------------------------------
#			FWnull
#---------------------------------------
if(GTKn_FOUND)
    set(FWnull TRUE)
endif()
#---------------------------------------

#---------------------------------------
#			GSnull
#---------------------------------------
if(GTKn_FOUND AND EXTRA_PLUGINS)
    set(GSnull TRUE)
endif()
#---------------------------------------

#---------------------------------------
#			GSdx
#---------------------------------------
# requires: -OpenGL
#           -PNG
#           -X11
#           -zlib
#---------------------------------------
if(OPENGL_FOUND AND X11_FOUND AND GTKn_FOUND AND ZLIB_FOUND AND PNG_FOUND AND FREETYPE_FOUND AND LIBLZMA_FOUND AND ((EGL_FOUND AND X11_XCB_FOUND) OR NOT EGL_API))
    set(GSdx TRUE)
elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/plugins/GSdx")
    set(GSdx FALSE)
else()
    set(GSdx FALSE)
    print_dep("Skip build of GSdx: missing dependencies" "${msg_dep_gsdx}")
endif()
#---------------------------------------

#---------------------------------------
#			zerogs
#---------------------------------------
# requires:	-GLEW
#			-OpenGL
#			-X11
#			-CG
#---------------------------------------
if(EXTRA_PLUGINS)
    if(GLEW_FOUND AND OPENGL_FOUND AND X11_FOUND AND CG_FOUND)
        set(zerogs TRUE)
    elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/plugins/zerogs")
        set(zerogs FALSE)
    else()
        set(zerogs FALSE)
        print_dep("Skip build of zerogs: missing dependencies" "${msg_dep_zerogs}")
    endif()
endif()
#---------------------------------------

#---------------------------------------
#			zzogl-pg
#---------------------------------------
# requires:	-GLEW
#			-OpenGL
#			-X11
#			-CG (only with cg build)
#			-JPEG
#           -common_libs
#---------------------------------------
if(EXTRA_PLUGINS)
    if((GLEW_FOUND AND OPENGL_FOUND AND X11_FOUND AND JPEG_FOUND AND common_libs AND GTKn_FOUND) AND (CG_FOUND OR GLSL_API))
        set(zzogl TRUE)
    elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/plugins/zzogl-pg")
        set(zzogl FALSE)
    else()
        set(zzogl FALSE)
        print_dep("Skip build of zzogl: missing dependencies" "${msg_dep_zzogl}")
    endif()
endif()
#---------------------------------------

#---------------------------------------
#			PadNull
#---------------------------------------
if(GTKn_FOUND AND EXTRA_PLUGINS)
    set(PadNull TRUE)
endif()
#---------------------------------------

#---------------------------------------
#			LilyPad
# requires: -X11
#---------------------------------------
# Not ready to be packaged
if(EXTRA_PLUGINS OR NOT PACKAGE_MODE)
    if(wxWidgets_FOUND AND Linux AND GTKn_FOUND AND X11_FOUND)
        set(LilyPad TRUE)
    endif()
endif()
#---------------------------------------

#---------------------------------------
#			onepad
#---------------------------------------
# requires: -SDL2
#			-X11
#---------------------------------------
if(wxWidgets_FOUND AND GTKn_FOUND AND SDL2_FOUND AND X11_FOUND)
	set(onepad TRUE)
elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/plugins/onepad")
	set(onepad FALSE)
else()
	set(onepad FALSE)
    print_dep("Skip build of onepad: missing dependencies" "${msg_dep_onepad}")
endif()

# old version of the plugin that still supports SDL1
# Was never ported to macOS
if(wxWidgets_FOUND AND GTKn_FOUND AND SDLn_FOUND AND X11_FOUND AND NOT APPLE)
	set(onepad_legacy TRUE)
elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/plugins/onepad_legacy" OR APPLE)
	set(onepad_legacy FALSE)
else()
	set(onepad_legacy FALSE)
    print_dep("Skip build of onepad_legacy: missing dependencies" "${msg_dep_onepad}")
endif()
#---------------------------------------

#---------------------------------------
#			SPU2null
#---------------------------------------
if(GTKn_FOUND AND EXTRA_PLUGINS)
    set(SPU2null TRUE)
endif()
#---------------------------------------

#---------------------------------------
#			spu2-x
#---------------------------------------
# requires: -SoundTouch
#           -ALSA
#           -SDL
#           -common_libs
#
# optional: -Portaudio
#---------------------------------------
if((SOUNDTOUCH_FOUND AND SDLn_FOUND AND common_libs)
	AND ((Linux AND ALSA_FOUND) OR (UNIX AND NOT Linux)))
	set(spu2-x TRUE)
elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/plugins/spu2-x")
	set(spu2-x FALSE)
else()
	set(spu2-x FALSE)
    print_dep("Skip build of spu2-x: missing dependencies" "${msg_dep_spu2x}")
endif()
#---------------------------------------

#---------------------------------------
#			zerospu2
#---------------------------------------
# requires: -SoundTouch
#           -ALSA
#           -PortAudio
#---------------------------------------
if(EXTRA_PLUGINS)
    if(EXISTS "${CMAKE_SOURCE_DIR}/plugins/zerospu2" AND SOUNDTOUCH_FOUND AND ALSA_FOUND)
        set(zerospu2 TRUE)
        # Comment the next line, if you want to compile zerospu2
        set(zerospu2 FALSE)
        message(STATUS "Don't build zerospu2. It is superceded by spu2x")
    elseif(NOT EXISTS "${CMAKE_SOURCE_DIR}/plugins/zerospu2")
        set(zerospu2 FALSE)
    else()
        set(zerospu2 FALSE)
        print_dep("Skip build of zerospu2: missing dependencies" "${msg_dep_zerospu2}")
    endif()
endif()
#---------------------------------------

#---------------------------------------
#			USBnull
#---------------------------------------
if(GTKn_FOUND)
    set(USBnull TRUE)
endif()
#---------------------------------------
#-------------------------------------------------------------------------------
