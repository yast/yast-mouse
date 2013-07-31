# encoding: utf-8

# *************
# FILE          : mouse.ycp
# ***************
# PROJECT       : YaST2 - Yet another Setup Tool
#               :
# AUTHOR        : Marcus Schäfer <ms@suse.de>
#               :
# BELONGS TO    : YaST2 - GPM mouse configuration
#               :
# DESCRIPTION   : mouse.ycp is the first instance called in
#               : front of the inst_mouse.ycp configuration module
#               : we will handle the reprobe case here and the
#               : return value from the configuration module which
#               : is needed to restore the mouse in special cases
#               :
#               :
# STATUS        : Development
# *************
#! \brief YaST2 - GPM configuration interface
#
# File:	clients/mouse.ycp
# Package:	Mouse configuration
# Summary:	Main client
# Authors:	Marcus Schäfer <ms@suse.de>
#
module Yast
  class MouseClient < Client
    def main
      Yast.import "UI"
      textdomain "mouse"

      #==========================================
      # Import...
      #------------------------------------------
      Yast.import "CommandLine"
      Yast.import "Confirm"
      Yast.import "Label"
      Yast.import "Stage"
      Yast.import "Mouse"
      Yast.import "Popup"
      Yast.import "Wizard"

      #==========================================
      # Memorize the current mouse.
      #------------------------------------------
      @mouse_on_entry = ""

      #==========================================
      # the command line description
      #------------------------------------------
      @cmdline = {
        "id"         => "mouse",
        "help"       => _("Mouse configuration."),
        "guihandler" => fun_ref(method(:MouseSequence), "any ()"),
        "initialize" => fun_ref(method(:MouseRead), "boolean ()"),
        "finish"     => fun_ref(method(:MouseWrite), "boolean ()"),
        "actions"    => {
          "summary" => {
            "handler" => fun_ref(method(:MouseSummaryHandler), "boolean (map)"),
            "help"    => _("Mouse configuration summary.")
          }
        }
      }

      #==========================================
      # Run the module
      #------------------------------------------
      CommandLine.Run(@cmdline)
      true
    end

    #==========================================
    # MouseRead
    #------------------------------------------
    def MouseRead
      @mouse_on_entry = Mouse.mouse
      Builtins.y2milestone(
        "Stage::reprobe %1 Mouse:%2",
        Stage.reprobe,
        Mouse.mouse
      )
      true
    end

    #==========================================
    # MouseWrite
    #------------------------------------------
    def MouseWrite
      Mouse.Save
      true
    end

    #==========================================
    # print mouse configuration summary
    #------------------------------------------
    def MouseSummaryHandler(options)
      options = deep_copy(options)
      Builtins.foreach(Mouse.Selection) do |mouse_code, name|
        if @mouse_on_entry == mouse_code
          CommandLine.Print(Builtins.sformat(_("Current Mouse Type: %1"), name))
        end
      end
      false
    end

    #==========================================
    # MouseSequence
    #------------------------------------------
    def MouseSequence
      display_info = UI.GetDisplayInfo
      if !Ops.get_boolean(display_info, "TextMode", true)
        # disable mouse module in non-Textmode (bnc#441404)
        Builtins.y2milestone(
          "YaST2 gpm (formerly known as 'mouse') was started in GUI mode. It is intended to configure the mouse for the console only. Mouse configuration for X is configured automatically by the X-Server."
        ) 
        #if (Confirm::MustBeRoot ())
        #{
        #  // call sax
        #  SCR::Execute (.target.bash, "/usr/sbin/sax2 -O Mouse");
        #  return `finish;
        #}
        #return `cancel;
      end

      MouseRead()
      #==========================================
      # Check if this is a reconfiguration run.
      #------------------------------------------
      if Stage.reprobe || @mouse_on_entry == "none"
        mouseID = Mouse.Probe
        Mouse.mouse = "none" if mouseID == "none"
        Mouse.Set(Mouse.mouse)
      end
      result = :cancel
      #==========================================
      # create the wizard dialog
      #------------------------------------------
      Wizard.CreateDialog

      #==========================================
      # check if no mouse is connected
      #------------------------------------------
      if Stage.reprobe && Mouse.mouse == "none"
        Popup.TimedMessage(_("No mouse connected to the system..."), 10)
        Builtins.y2milestone("No mouse detected --> unchanged")
        return UI.CloseDialog
      end

      #==========================================
      # call inst_mouse and init mouse list
      #------------------------------------------
      result = WFM.CallFunction("inst_mouse", [true, true])

      #==========================================
      # handle result value from the config
      #------------------------------------------
      if result == :next
        # ...
        # User accepted the the setting.
        # Only if the user has chosen a different mouse change the
        # system configuration.
        # ---
        Builtins.y2milestone("User selected new mouse: <%1>", Mouse.mouse)
        MouseWrite()
      else
        # ...
        # `cancel or `back selected
        # ---
        Builtins.y2milestone("User cancelled --> no change")
      end
      UI.CloseDialog
      deep_copy(result)
    end
  end
end

Yast::MouseClient.new.main
