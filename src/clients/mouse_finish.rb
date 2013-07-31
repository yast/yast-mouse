# encoding: utf-8

# File:
#  mouse_finish.ycp
#
# Module:
#  Step of base installation finish
#
# Authors:
#  Lukas Ocilka <locilka@suse.cz>
#
# $Id$
#
module Yast
  class MouseFinishClient < Client
    def main

      # This client exists because yast2-installation package
      # needn't installed yast2-mouse anymore
      #
      # SCR::Write is called before SCR is switched to the installed system

      textdomain "mouse"

      Yast.import "Progress"
      Yast.import "Installation"
      Yast.import "Mouse"
      Yast.import "FileUtils"
      Yast.import "String"

      @ret = nil
      @func = ""
      @param = {}

      # Check arguments
      if Ops.greater_than(Builtins.size(WFM.Args), 0) &&
          Ops.is_string?(WFM.Args(0))
        @func = Convert.to_string(WFM.Args(0))
        if Ops.greater_than(Builtins.size(WFM.Args), 1) &&
            Ops.is_map?(WFM.Args(1))
          @param = Convert.to_map(WFM.Args(1))
        end
      end

      Builtins.y2milestone("starting mouse_finish")
      Builtins.y2debug("func=%1", @func)
      Builtins.y2debug("param=%1", @param)

      if @func == "Info"
        return { "steps" => 1, "when" => [:installation, :update, :autoinst] }
      elsif @func == "Write"
        @sysconfigdir = "/etc/sysconfig/"
        @sysconfigfile = "/etc/sysconfig/mouse"

        # Create local sysconfig directory
        SCR.Execute(path(".target.mkdir"), @sysconfigdir)
        if !FileUtils.Exists(@sysconfigdir)
          Builtins.y2error("Directory %1 does not exist!", @sysconfigdir)
        end

        # Copy file from installed system if already exists
        if FileUtils.Exists(Ops.add(Installation.destdir, @sysconfigfile))
          Builtins.y2milestone(
            "copy %1 -> %2",
            Ops.add(Installation.destdir, @sysconfigfile),
            @sysconfigfile
          )
          SCR.Execute(
            path(".target.bash"),
            Builtins.sformat(
              "cp '%1' '%2'",
              String.Quote(Ops.add(Installation.destdir, @sysconfigfile)),
              String.Quote(@sysconfigfile)
            )
          )
        end

        # Create mouse sysconfig file if does not exist
        if !FileUtils.Exists(@sysconfigfile)
          Builtins.y2milestone("Create %1", @sysconfigfile)
          SCR.Execute(
            path(".target.bash"),
            Builtins.sformat("touch '%1'", String.Quote(@sysconfigfile))
          )
        end

        # progress step title
        Progress.Title(_("Saving mouse configuration..."))
        # Save the configuration
        @ret = Mouse.Save
        Progress.NextStep

        # Copy to the installed system
        Builtins.y2milestone(
          "Copy %1 -> %2",
          @sysconfigfile,
          Ops.add(Installation.destdir, @sysconfigfile)
        )
        @cmd = Convert.to_map(
          SCR.Execute(
            path(".target.bash_output"),
            Builtins.sformat(
              "cp '%1' '%2'",
              String.Quote(@sysconfigfile),
              String.Quote(Ops.add(Installation.destdir, @sysconfigfile))
            )
          )
        )

        if Ops.get_integer(@cmd, "exit", -1) != 0
          Builtins.y2error(
            "Cannot copy '%1' to '%2': %3",
            @sysconfigfile,
            Ops.add(Installation.destdir, @sysconfigfile),
            @cmd
          )
          @ret = false
        else
          @ret = true
        end
      else
        Builtins.y2error("unknown function: %1", @func)
        @ret = nil
      end

      Builtins.y2debug("ret=%1", @ret)
      Builtins.y2milestone("mouse_finish finished")
      deep_copy(@ret)
    end
  end
end

Yast::MouseFinishClient.new.main
