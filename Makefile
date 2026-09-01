TARGET := iphone:clang:11.4:8.0
ARCHS = armv7 arm64
INSTALL_TARGET_PROCESSES = ComicFlow

include $(THEOS)/makefiles/common.mk

# ==============================================================================
# ФАЗА 1: Сборка статических библиотек (libGCDWebServer.a и libXLFacility.a)
# ==============================================================================
LIBRARY_NAME = libGCDWebServer libXLFacility

# --- Настройки libGCDWebServer ---
libGCDWebServer_LINKAGE_TYPE = static
libGCDWebServer_FILES = $(shell find GCDWebServer/GCDWebServer GCDWebServer/GCDWebUploader GCDWebServer/GCDWebDAVServer -type f -name "*.m")
libGCDWebServer_CFLAGS = -fobjc-arc \
    -I./GCDWebServer/GCDWebServer/Core \
    -I./GCDWebServer/GCDWebServer/Requests \
    -I./GCDWebServer/GCDWebServer/Responses \
    -I./GCDWebServer/GCDWebDAVServer \
    -I./GCDWebServer/GCDWebUploader \
    -I$(SYSROOT)/usr/include/libxml2
libGCDWebServer_FRAMEWORKS = MobileCoreServices CFNetwork Security
libGCDWebServer_LDFLAGS = -lxml2

# --- Настройки libXLFacility ---
libXLFacility_LINKAGE_TYPE = static
ALL_XL_FILES = $(shell find \
    XLFacility/XLFacility/Core \
    XLFacility/XLFacility/Extensions \
    XLFacility/XLFacility/UserInterface \
    XLFacility/GCDTelnetServer/GCDNetworking/GCDNetworking \
    XLFacility/GCDTelnetServer/GCDTelnetServer \
    -type f -name "*.m")

XL_EXCLUDES = XLFacility/XLFacility/UserInterface/XLAppKitOverlayLogger.m
libXLFacility_FILES = $(filter-out $(XL_EXCLUDES), $(ALL_XL_FILES))

libXLFacility_CFLAGS = -fobjc-arc \
    -I./XLFacility/XLFacility/Core \
    -I./XLFacility/XLFacility/Extensions \
    -I./XLFacility/XLFacility/UserInterface \
    -I./XLFacility/GCDTelnetServer/GCDNetworking/GCDNetworking \
    -I./XLFacility/GCDTelnetServer/GCDTelnetServer

# Подключаем правила для библиотек (Theos скомпилирует их в .theos/obj/)
include $(THEOS_MAKE_PATH)/library.mk


# ==============================================================================
# ФАЗА 2: Сборка приложения ComicFlow
# ==============================================================================
APPLICATION_NAME = ComicFlow

ALL_COMICFLOW_FILES = $(shell find Classes libwebp Minizip-1.1 UnRAR-3.9.10 Cooliris-ToolKit -type f \( -name "*.m" -o -name "*.mm" -o -name "*.c" -o -name "*.cpp" \))

UNRAR_EXCLUDES = UnRAR-3.9.10/unpack11.cpp \
                 UnRAR-3.9.10/unpack15.cpp \
                 UnRAR-3.9.10/unpack20.cpp \
                 UnRAR-3.9.10/suballoc.cpp \
                 UnRAR-3.9.10/uowners.cpp \
                 UnRAR-3.9.10/rarvmtbl.cpp \
                 UnRAR-3.9.10/coder.cpp \
                 UnRAR-3.9.10/model.cpp \
                 UnRAR-3.9.10/win32acl.cpp \
                 UnRAR-3.9.10/win32stm.cpp \
                 UnRAR-3.9.10/arccmt.cpp \
                 UnRAR-3.9.10/unios2.cpp \
                 UnRAR-3.9.10/os2ea.cpp \
                 UnRAR-3.9.10/beosea.cpp \
                 UnRAR-3.9.10/log.cpp \
                 Cooliris-ToolKit/Classes/ApplicationDelegate.m \
                 Cooliris-ToolKit/Classes/UnitTest.m \
                 Cooliris-ToolKit/Classes/Database_UnitTests.m \
                 Cooliris-ToolKit/Classes/HTTPURLConnection_UnitTests.m \
                 Cooliris-ToolKit/Classes/PubNub_UnitTests.m

ComicFlow_FILES = main.m \
    $(filter-out $(UNRAR_EXCLUDES), $(ALL_COMICFLOW_FILES))

ComicFlow_CFLAGS = -include Prefix.pch -DRARDLL -DUNRAR -D_UNIX
ComicFlow_CFLAGS += -Wno-error -Wno-deprecated-declarations
ComicFlow_CFLAGS += -Dfopen64=fopen -Dftello64=ftello -Dfseeko64=fseeko

ComicFlow_CFLAGS += -I./Classes \
    -I./GCDWebServer/GCDWebServer/Core \
    -I./GCDWebServer/GCDWebServer/Requests \
    -I./GCDWebServer/GCDWebServer/Responses \
    -I./GCDWebServer/GCDWebDAVServer \
    -I./GCDWebServer/GCDWebUploader \
    -I./libwebp/iPhoneOS/include \
    -I./Minizip-1.1 \
    -I./UnRAR-3.9.10 \
    -I./Cooliris-ToolKit/Classes \
    -I./XLFacility/XLFacility/Core \
    -I./XLFacility/XLFacility/Extensions \
    -I./XLFacility/XLFacility/UserInterface \
    -I./XLFacility/GCDTelnetServer/GCDNetworking/GCDNetworking \
    -I./XLFacility/GCDTelnetServer/GCDTelnetServer \
    -I$(SYSROOT)/usr/include/libxml2

# ВАЖНО: Так как библиотеки статические и лежат внутри приватной папки сборки .theos, 
# мы указываем линкеру путь к ним напрямую через LDFLAGS
ComicFlow_LDFLAGS = -lc++ -lz -lxml2 -ObjC -L$(THEOS_OBJ_DIR) -lGCDWebServer -lXLFacility ./libwebp/iPhoneOS/lib/libwebp.a

ComicFlow_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore CFNetwork MobileCoreServices Security

# Подключаем правила для приложения
include $(THEOS_MAKE_PATH)/application.mk

