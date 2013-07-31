# encoding: utf-8

# File:	clients/inst_init_mouse.ycp
# Package:	Installation
# Summary:	Installation mode selection, initializing mouse
# Authors:	Lukas Ocilka <locilka@suse.cz>
#
# $Id$
#
module Yast
  class InstInitMouseClient < Client
    def main
      Yast.import "UI"
      textdomain "installation"

      Yast.import "Mouse"

      UI.BusyCursor
      Builtins.y2milestone("Call Mouse probing...")
      Mouse.Set(Mouse.Probe)
      UI.NormalCursor

      true 

      # EOF
    end
  end
end

Yast::InstInitMouseClient.new.main
