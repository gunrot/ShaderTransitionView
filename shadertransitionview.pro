TEMPLATE = lib
TARGET = ShaderTransitionView
QT += qml quick
CONFIG += qt plugin c++11

TARGET = $$qtLibraryTarget($$TARGET)
uri = ShaderTransitionView

# Input
SOURCES += \
    shadertransitionview_plugin.cpp \
    shadertransitionview.cpp

HEADERS += \
    shadertransitionview_plugin.h \
    shadertransitionview.h



DISTFILES = README.md qmldir

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir

installPath = $$[QT_INSTALL_QML]/$$replace(uri, \\., /)
qmldir.path = $$installPath
target.path = $$installPath
qmldir_private.path = $$installPath/private
INSTALLS += target qmldir qmldir_private

RESOURCES += \
    qml.qrc \
    private/gl-transitions.qrc

