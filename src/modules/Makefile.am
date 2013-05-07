#
# Makefile.am for y2c_mouse/src/modules
#

YCPCFLAGS = -I . -M .

module_DATA = 				\
	Mouse.ycp

EXTRA_DIST = $(module_DATA)


mouse:
	ln -sf ../include/mouse mouse

ycpchook = mouse

include $(top_srcdir)/Makefile.am.common
