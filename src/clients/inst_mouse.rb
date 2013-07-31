# encoding: utf-8

# *************
# FILE          : inst_mouse.ycp
# ***************
# PROJECT       : YaST2 - Yet another Setup Tool
#               :
# AUTHOR        : Marcus Schäfer <ms@suse.de>
#               :
# BELONGS TO    : YaST2 - GPM mouse configuration
#               :
# DESCRIPTION   : mouse.ycp will call inst_mouse to initialize
#               : the target system GUI
#               :
# STATUS        : Development
# *************
#! \brief YaST2 - GPM configuration interface
#
# File:	inst_mouse.ycp
# Package:	Mouse configuration
# Summary:	Main client
# Authors:	Marcus Schäfer <ms@suse.de>
module Yast
  class InstMouseClient < Client
    def main
      Yast.import "UI"
      textdomain "mouse"
      #==========================================
      # Imports...
      #------------------------------------------
      Yast.import "Mode"
      Yast.import "Stage"
      Yast.import "Mouse"
      Yast.import "Wizard"
      Yast.import "Popup"
      Yast.import "GetInstArgs"

      #==========================================
      # Globals...
      #------------------------------------------
      @mouse_on_entry = Mouse.mouse
      @mouse = Mouse.mouse

      #==========================================
      # Build dialog
      #------------------------------------------
      @mouse = "00_ps2" if Mode.test
      @probe_mouse_check_button = Empty()
      @test_button = Empty()

      if Mode.config
        Wizard.HideAbortButton
      else
        Wizard.OpenAcceptDialog 
        #test_button = `PushButton( `id(`apply), _("&Test") );
      end

      @contents = VBox(
        SelectionBox(
          Id(:mouse),
          _("Choose your &mouse type from the list"),
          Builtins.maplist(Mouse.Selection) do |mouse_code, mouse_name|
            Item(Id(mouse_code), mouse_name, @mouse == mouse_code)
          end
        ),
        @probe_mouse_check_button,
        VSpacing(0.3),
        @test_button,
        VSpacing(0.5)
      )

      #==========================================
      # help texts
      #------------------------------------------
      @help_text = _(
        "<p>\n" +
          "Choose the <b>mouse type</b> of the mouse attached to your computer.\n" +
          "</p>\n"
      )

      @help_text = Ops.add(
        @help_text,
        _(
          "<p>\n" +
            "Use the arrow keys to select a mouse. If the selection bar does not\n" +
            "move, hit the <b><i>Tab</i></b> key (maybe repeatedly) until it does.\n" +
            "</p>\n"
        )
      )

      @help_text = Ops.add(
        @help_text,
        _(
          "<p>\n" +
            "If you select <b>None</b>, you have to use the keyboard as\n" +
            "described in the manual.\n" +
            "</p>"
        )
      )

      Wizard.SetContents(
        _("Mouse configuration"),
        @contents,
        @help_text,
        GetInstArgs.enable_back,
        GetInstArgs.enable_next
      )

      if Stage.initial
        Wizard.SetTitleIcon("mouse")
      else
        Wizard.SetDesktopTitleAndIcon("mouse")
      end

      Mouse.Set(Mouse.mouse)

      @ret = nil
      begin
        # In this dialog only, set the keyboard focus to the mouse
        # selection box for every iteration of the input loop. If
        # anything goes wrong here, the user has a hard enough time
        # getting his system to work-  even without having to worry about
        # how to get the keyboard focus into the list. He most likely
        # doesn't have a working mouse right now (otherwise he wouldn't
        # be here in the first place).
        UI.SetFocus(Id(:mouse))
        @ret = Wizard.UserInput

        break if !Mode.config && @ret == :abort && Popup.ConfirmAbort(:painless)

        if @ret == :next || @ret == :apply
          @new_mouse = Convert.to_string(
            UI.QueryWidget(Id(:mouse), :CurrentItem)
          )

          if @new_mouse != nil
            Mouse.Set(@new_mouse)
            if Mode.config
              Yast.import "AutoinstData"
              Ops.set(AutoinstData.mouse, "id", Mouse.mouse)
            end
          end

          if @ret == :next && @new_mouse != @mouse_on_entry
            Builtins.y2milestone(
              "Clearing unique key <%1> due to manual selection",
              Mouse.unique_key
            )
            Mouse.unique_key = ""
          end
        end
      end until @ret == :next || @ret == :back || @ret == :cancel

      if @ret == :back || @ret == :cancel
        Builtins.y2milestone(
          "`back or `cancel restoring: <%1>",
          @mouse_on_entry
        )
        Mouse.Set(@mouse_on_entry)
      end

      Wizard.CloseDialog
      deep_copy(@ret)
    end
  end
end

Yast::InstMouseClient.new.main
