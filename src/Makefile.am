# Sources for mouse

module_DATA = \
  modules/Mouse.rb

client_DATA = \
  clients/inst_mouse.rb \
  clients/mouse_finish.rb \
  clients/inst_init_mouse.rb \
  clients/mouse.rb \
  clients/mouse_proposal.rb

yncludedir = @yncludedir@/mouse
ynclude_DATA = \
  include/mouse/mouse_raw.rb

scrconf_DATA = \
  scrconf/cfg_gpm.scr \
  scrconf/cfg_mouse.scr

desktop_DATA = \
  desktop/mouse.desktop

EXTRA_DIST = $(module_DATA) $(client_DATA) $(ynclude_DATA) $(scrconf_DATA) $(desktop_DATA)

include $(top_srcdir)/Makefile.am.common