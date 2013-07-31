# encoding: utf-8

# *************
# FILE          : mouse_proposal.ycp
# ***************
# PROJECT       : YaST2
#               :
# AUTHOR        : Marcus Schäfer <ms@suse.de>
#               :
# BELONGS TO    : YaST2 - Mouse information proposal for the GPM
#               :
# DESCRIPTION   : Proposal function dispatcher for
#               : GPM mouse configuration
#               :
#               :
# STATUS        : Development
# *************
#! \brief YaST2 - GPM configuration interface
#
# File:        proposal/mouse_proposal.ycp
# Package:     GPM Configuration
# Summary:     Installation Proposal for GPM mouse
# Authors:     Marcus Schaefer <ms@suse.de>
#
module Yast
  class MouseProposalClient < Client
    def main
      textdomain "mouse"

      Yast.import "Mouse"
      Yast.import "Linuxrc"

      #===================================================
      # Initialize proposal parameters
      #---------------------------------------------------
      @func = Convert.to_string(WFM.Args(0))
      @param = Convert.to_map(WFM.Args(1))
      @ret = {}

      #===================================================
      # Handle installation environment
      #---------------------------------------------------
      if !Linuxrc.text
        if @func != "Description"
          @ret = {
            "rich_text_title"       => "",
            "menu_title"            => "",
            "id"                    => "",
            "preformatted_proposal" => "<b> </b>",
            "success"               => true
          }
          return deep_copy(@ret)
        else
          return deep_copy(@ret)
        end
      end
      #===================================================
      # Create proposal for installation/configuration...
      #---------------------------------------------------
      if @func == "MakeProposal"
        @force_reset = Ops.get_boolean(@param, "force_reset", false)
        @language_changed = Ops.get_boolean(@param, "language_changed", false)
        @ret = {
          "raw_proposal"     => [
            Mouse.MakeProposal(@force_reset, @language_changed)
          ],
          "language_changed" => false
        }
      #===================================================
      # Handle user requests...
      #---------------------------------------------------
      elsif @func == "AskUser"
        @has_next = Ops.get_boolean(@param, "has_next", false)
        @result = Convert.to_symbol(
          WFM.CallFunction("inst_mouse", [true, @has_next])
        )
        @ret = { "workflow_sequence" => @result, "language_changed" => false }
      #===================================================
      # Handle proposal description...
      #---------------------------------------------------
      elsif @func == "Description"
        @ret = {
          "rich_text_title" => _("Mouse"),
          "menu_title"      => _("&Mouse"),
          "id"              => "mouse_stuff"
        }
      end
      deep_copy(@ret)
    end
  end
end

Yast::MouseProposalClient.new.main
