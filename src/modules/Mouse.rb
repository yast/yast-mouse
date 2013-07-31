# encoding: utf-8

# *************
# FILE          : Mouse.ycp
# ***************
# PROJECT       : YaST2 - Yet another Setup Tool
#               :
# AUTHOR        : Marcus Schäfer <ms@suse.de>
#               :
# BELONGS TO    : YaST2 - GPM mouse setup NOT X11 Mouse !
#               :
# DESCRIPTION   : YaST module: Provide a simple configuration
#               : for textmode mouse configuration (GPM)
#               :
# STATUS        : Development
# *************
#! \brief YaST2 - mouse configuration interface (GPM)
#
# File:        Mouse.ycp
# Package:     GPM Configuration
# Summary:     Main Module started if yast2 mouse is called
# Authors:     Marcus Schaefer <ms@suse.de>
require "yast"

module Yast
  class MouseClass < Module
    def main

      textdomain "mouse"
      #==========================================
      # Imports...
      #------------------------------------------
      Yast.import "Arch"
      Yast.import "Misc"
      Yast.import "Mode"
      Yast.import "Stage"
      Yast.import "Linuxrc"
      Yast.import "ModuleLoading"

      #==========================================
      # Globals accessed via Mouse::<variable>
      #------------------------------------------
      @mouse = "none" # current mouse
      @mset = "" # x11 config values
      @gpm = "" # gpm config values
      @device = "" # mouse device
      @emul3 = false # emulate 3 buttons ?
      @wheels = 0 # number of wheels
      @buttons = 0 # number of buttons
      @name = "" # user readable name
      @unique_key = "" # unique key

      #==========================================
      # Module globals
      #------------------------------------------
      @already_probed = false # memorize if already probed
      @plist = [] # list got from last probing
      @mice = {}
      @first_proposal = true

      Yast.include self, "mouse/mouse_raw.rb"
      Mouse()
    end

    #==========================================
    # Restore...
    #------------------------------------------
    def Restore
      # ...
      # Restore the the data from sysconfig.
      # ---
      @mouse = Misc.SysconfigRead(path(".sysconfig.mouse.YAST_MOUSE"), @mouse)
      @device = Misc.SysconfigRead(
        path(".sysconfig.mouse.MOUSEDEVICE"),
        @device
      )
      @gpm = Misc.SysconfigRead(path(".sysconfig.mouse.MOUSETYPE"), "")
      if @gpm == ""
        # Try to read old variable for compatibility on update of old system
        @gpm = Misc.SysconfigRead(path(".sysconfig.mouse.GPM_PROTOCOL"), "")
      end
      @name = Misc.SysconfigRead(path(".sysconfig.mouse.FULLNAME"), @name)
      @emul3 = Misc.SysconfigRead(
        path(".sysconfig.mouse.XEMU3"),
        @emul3 ? "yes" : "no"
      ) == "yes"
      @mset = Misc.SysconfigRead(path(".sysconfig.mouse.XMOUSETYPE"), @mset)
      @buttons = Builtins.tointeger(
        Misc.SysconfigRead(
          path(".sysconfig.mouse.BUTTONS"),
          Builtins.sformat("%1", @buttons)
        )
      )
      @wheels = Builtins.tointeger(
        Misc.SysconfigRead(
          path(".sysconfig.mouse.WHEELS"),
          Builtins.sformat("%1", @wheels)
        )
      )
      Builtins.y2milestone("Restored data (sysconfig) for mouse: <%1>", @mouse)
      true
    end

    #==========================================
    # Functions...
    #------------------------------------------
    def Mouse
      # ...
      # The module constructor.
      # Sets the proprietary module data defined globally for public access.
      # This is done only once (and automatically) when the module is
      # loaded for the first time.
      # ---
      Builtins.y2milestone(
        "Stage::initial %1 Mode::config %2 Mode::rep %3 Mode::cont %4",
        Stage.initial,
        Mode.config,
        Stage.reprobe,
        Stage.cont
      )
      return if Stage.initial || Mode.config
      # ...
      # Running system: Restore formerly stored state
      # from sysconfig.
      # ---
      Restore()
      Set(@mouse) if Ops.greater_than(Builtins.size(@mouse), 0) && Stage.cont

      nil
    end

    #==========================================
    # do_really_probe...
    #------------------------------------------
    def do_really_probe(manual)
      # ...
      # Do a hardware probing of the attached mouse. Depending on the
      # parameter "manual" this is done by really probing the mouse
      # hardware or by just reading the libhd database.
      # ---
      Builtins.y2milestone("Probing for mouse hardware...")
      mouseprobelist = []
      if manual
        # libhd data lookup...
        mouseprobelist = Convert.convert(
          SCR.Read(path(".probe.mouse.manual")),
          :from => "any",
          :to   => "list <map>"
        )
        Builtins.y2milestone(
          "Probed manual (no HW interception): <%1>",
          mouseprobelist
        )
        mouseprobelist = [] if mouseprobelist == nil
        if mouseprobelist == []
          # ...
          # Data lookup not successful ==> Trying a real
          # hardware probing as fallback
          # ---
          Builtins.y2warning(
            "Manual probing failed ==> Now trying a real HW Probing"
          )
          return do_really_probe(false)
        end
      else
        # real hardware interception...
        mouseprobelist = Convert.convert(
          SCR.Read(path(".probe.mouse")),
          :from => "any",
          :to   => "list <map>"
        )
        Builtins.y2milestone(
          "Really probed with HW interception: <%1>",
          mouseprobelist
        )
        mouseprobelist = [] if mouseprobelist == nil
        if mouseprobelist != []
          # ...
          # Probing was successful ==>  Now probing has taken place
          # ---
          @already_probed = true
        end
      end
      if Ops.greater_than(Builtins.size(mouseprobelist), 0)
        # ...
        # found a mouse -> get value from bus, select first mouse only
        #
        firstmouse = {}
        idx = 0
        while Builtins.size(firstmouse) == 0 &&
            Ops.less_than(idx, Builtins.size(mouseprobelist))
          conf = Convert.to_map(
            SCR.Read(
              path(".probe.status"),
              Ops.get_string(mouseprobelist, [idx, "unique_key"], "")
            )
          )
          Builtins.y2milestone(
            "key %1 conf %2",
            Ops.get_string(mouseprobelist, [idx, "unique_key"], ""),
            conf
          )
          if Ops.get_symbol(conf, "available", :no) == :yes
            firstmouse = Ops.get(mouseprobelist, idx, {})
          end
          idx = Ops.add(idx, 1)
        end
        @device = Ops.get_string(firstmouse, "dev_name", "")
        @unique_key = Ops.get_string(firstmouse, "unique_key", "")
        bus = Ops.get_string(firstmouse, "bus", "")
        mprotocol = Ops.get_map(firstmouse, ["mouse", 0], {})
        Builtins.y2milestone("mprotocol: <%1>", mprotocol)

        @buttons = Ops.get_integer(mprotocol, "buttons", 0)
        @wheels = Ops.get_integer(mprotocol, "wheels", 0)
        @gpm = Ops.get_string(mprotocol, "gpm", "")
        @mset = Ops.get_string(mprotocol, "xf86", "")
        @emul3 = Ops.get_boolean(mprotocol, "emul3", Ops.less_than(@buttons, 3))
        # ...
        # search mouse in raw database (file access)
        # ---
        @mice = get_mouse_db
        tl = Builtins.maplist(@mice) do |mouse_id, mouse_data|
          Ops.set(mouse_data, [1, "id"], mouse_id)
          deep_copy(mouse_data)
        end
        tl = Builtins.filter(tl) do |mouse_data|
          Ops.get_string(mouse_data, [1, "gpm"], "") == @gpm &&
            Ops.get_string(mouse_data, [1, "device"], "") == @device
        end
        Builtins.y2milestone("gpm %1 device %2 bus %3", @gpm, @device, bus)
        Builtins.y2milestone("tl = %1", tl)
        if Ops.greater_than(Builtins.size(tl), 1)
          if Builtins.find(tl) { |md| Ops.get_string(md, [1, "bus"], "") == bus } != nil
            tl = Builtins.filter(tl) do |md|
              Ops.get_string(md, [1, "bus"], "") == bus
            end
            Builtins.y2milestone("tl = %1", tl)
          end
        end
        @mouse = Ops.get_string(tl, [0, 1, "id"], "none")
        Builtins.y2milestone("found mouse %1", @mouse)
      end
      if @mouse == "none"
        Builtins.y2warning("No mouse found, probed '%1'", mouseprobelist)
      end
      Builtins.y2milestone("Mouse::Probe %1", @mouse)
      Builtins.y2milestone("unique_key %1", @unique_key)
      deep_copy(mouseprobelist)
    end

    #==========================================
    # Probe...
    #------------------------------------------
    def Probe
      # ...
      # Probe for mouse, return mouse_id for use with Set.
      # This is a "real" probe only under certain circunstances...
      # ---
      @mouse = "none"
      # ...
      # Don't expect a mouse with serial console.
      #
      return @mouse if Linuxrc.serial_console || Arch.s390
      # ...
      # During installation actually do probe only if called the
      # first time. Afterwards only read the libhd data base.
      # Probing in the running system (under X11) currently doesn't
      # work.
      # ---
      if Stage.initial
        if @already_probed
          # already probed
          Builtins.y2milestone("Initial: manual probing")
          @plist = do_really_probe(true)
        else
          # not yet probed
          Builtins.y2milestone("Initial: real HW-probing")
          @plist = do_really_probe(false)
        end
      elsif Stage.reprobe
        # reprobe for mouse hardware
        Builtins.y2milestone("Reprobe: real HW-probing")
        @plist = do_really_probe(false)
      else
        # ...
        # When called from within the running system we can safely read
        # the libhd database to avoid erroneous HW-probing under Y11.
        # ---
        Builtins.y2milestone("Running system: manual probing")
        @plist = do_really_probe(true)
      end
      Builtins.y2milestone("plist %1", @plist)
      @mouse
    end

    #==========================================
    # Set...
    #------------------------------------------
    def Set(mouse_id)
      # ...
      # Set system to selected mouse.
      # Load modules, set global variables, call xmset.
      # ---
      Builtins.y2milestone("Mouse::Set (%1)", mouse_id)
      if (mouse_id == "19_usb" || mouse_id == "23_exps2" ||
          mouse_id == "21_imps2") &&
          !Mode.config
        if Mode.test
          Builtins.y2milestone("Testmode - not loading modules")
        else
          Builtins.y2milestone(
            "Hopefully all USB modules are loaded via hotplug"
          ) 
          # ...
        end
      end
      # ...
      # Get mouse data base for possible retranslation.
      # ---
      @mice = get_mouse_db
      @name = Ops.get_string(@mice, [mouse_id, 0], mouse_id)
      Builtins.y2milestone("Mouse '%1', name '%2'", mouse_id, @name)
      # ...
      # Overwrite perhaps probed data only if the
      # mouse could be found in the DB.
      #
      if @name != ""
        mouse_data = Ops.get_map(@mice, [mouse_id, 1], {})
        @device = Ops.get_string(mouse_data, "device", "")
        @gpm = Ops.get_string(mouse_data, "gpm", "")
        @mset = Ops.get_string(mouse_data, "mset", "")
        @emul3 = Ops.get_boolean(mouse_data, "emul3", false)
        @wheels = Ops.get_integer(mouse_data, "wheels", 0)
      end
      @mouse = mouse_id
      nil
    end


    #==========================================
    # MakeProposal...
    #------------------------------------------
    def MakeProposal(force_reset, language_changed)
      # ...
      # Return proposal string and set system mouse.
      # ---
      Builtins.y2milestone(
        "MakeProposal force_reset: %1 language_changed: %2",
        force_reset,
        language_changed
      )
      n = ""
      if Builtins.size(@mice) == 0 || @first_proposal || language_changed
        @mice = get_mouse_db
      end
      @first_proposal = false

      if force_reset
        mouse_id = Probe()
        @mouse = "none" if mouse_id == "none"
        Set(@mouse)
      end
      n = Ops.get_string(@mice, [@mouse, 0], @mouse)
      Builtins.y2milestone("MakeProposal ret: %1", n)
      n
    end

    #==========================================
    # Found...
    #------------------------------------------
    def Found
      # ...
      # Report if a mouse was alread found.
      # ---
      @mouse != "none"
    end

    #==========================================
    # Selection...
    #------------------------------------------
    def Selection
      # ...
      # Return a map of ids and names to build up a selection list
      # for the user. The key is used later in the Set function
      # to select this mouse. The name is a translated string.
      # ---
      # try translated mouse.ycp first, if this doesnt exist
      # use the raw (untranslated) version
      # ---
      mouse_name = ""
      @mice = get_mouse_db
      selection = Builtins.mapmap(@mice) do |mouse_code, mouse_value|
        mouse_name = Ops.get_string(mouse_value, 0, "")
        { mouse_code => mouse_name }
      end
      if Mode.config
        # save translated label text
        Ops.set(selection, "probe", _("Probe"))
      end
      deep_copy(selection)
    end

    #==========================================
    # Save...
    #------------------------------------------
    def Save
      # ...
      # Save state to target.
      # ---
      return if Mode.update
      Builtins.y2milestone(
        "device %1 mouse %2 reprobe:%3",
        @device,
        @mouse,
        Stage.reprobe
      )
      if @device != "" || @mouse == "none" || Stage.reprobe
        # if we have a mouse device, set gpm_param
        SCR.Write(path(".sysconfig.mouse.FULLNAME"), @name)
        SCR.Write(
          path(".sysconfig.mouse.FULLNAME.comment"),
          "\n" +
            "# The full name of the attached mouse.\n" +
            "#\n"
        )
        SCR.Write(path(".sysconfig.mouse.YAST_MOUSE"), @mouse)
        SCR.Write(
          path(".sysconfig.mouse.YAST_MOUSE.comment"),
          "\n" +
            "# The YaST-internal identifier of the attached mouse.\n" +
            "#\n"
        )
        SCR.Write(path(".sysconfig.mouse.MOUSEDEVICE"), @device)
        # Comment written by third party
        SCR.Write(path(".sysconfig.mouse.XMOUSEDEVICE"), @device)
        SCR.Write(
          path(".sysconfig.mouse.XMOUSEDEVICE.comment"),
          "\n" +
            "# Mouse device used for the X11 system.\n" +
            "#\n"
        )
        SCR.Write(
          path(".sysconfig.mouse.BUTTONS"),
          Builtins.sformat("%1", @buttons)
        )
        SCR.Write(
          path(".sysconfig.mouse.BUTTONS.comment"),
          "\n" +
            "# The number of buttons of the attached mouse.\n" +
            "#\n"
        )
        SCR.Write(
          path(".sysconfig.mouse.WHEELS"),
          Builtins.sformat("%1", @wheels)
        )
        SCR.Write(
          path(".sysconfig.mouse.WHEELS.comment"),
          "\n" +
            "# The number of wheels of the attached mouse.\n" +
            "#\n"
        )
        if @mset != ""
          SCR.Write(path(".sysconfig.mouse.XMOUSETYPE"), @mset)
          SCR.Write(
            path(".sysconfig.mouse.XMOUSETYPE.comment"),
            "\n" +
              "# The mouse type under X11, e.g. \"ps/2\"\n" +
              "#\n"
          )
          SCR.Write(path(".sysconfig.mouse.MOUSETYPE"), @gpm)
          SCR.Write(
            path(".sysconfig.mouse.MOUSETYPE.comment"),
            "\n# The GPM mouse type, e.g. \"ps2\"\n#\n"
          )
        end
        SCR.Write(path(".sysconfig.mouse"), nil) # flush
        Builtins.y2milestone("Saved sysconfig data for mouse: <%1>", @name)
      end
      # ...
      # Only if the mouse has been probed in this run the unique_key
      # is not empty. Only in this case mark the device as "configured".
      # In any other case the device should already be configured and
      # the marking can't be done because the unique_key is missing.
      # ==> Only mark after probing!
      #
      Builtins.y2milestone("configured mouse key %1", @unique_key)
      if @unique_key != ""
        SCR.Write(path(".probe.status.configured"), @unique_key, :yes)
        Builtins.y2milestone("Marked mouse <%1> as configured", @unique_key)
        if !Linuxrc.serial_console
          SCR.Write(path(".probe.status.needed"), @unique_key, :yes)
          Builtins.y2milestone("Marked mouse <%1> as needed", @unique_key)
        end
      end
      Builtins.foreach(@plist) do |e|
        Builtins.y2milestone("unique_key %2 entry %1", e, @unique_key)
        if Ops.get_string(e, "unique_key", "") != @unique_key
          Builtins.y2milestone(
            "set needed to no for key %1",
            Ops.get_string(e, "unique_key", "")
          )
          SCR.Write(
            path(".probe.status.needed"),
            Ops.get_string(e, "unique_key", ""),
            :no
          )
        end
      end if Stage.initial(
      ) ||
        Stage.reprobe
      Builtins.y2milestone("Saved data for mouse: <%1>", @name)
      nil
    end

    publish :variable => :mouse, :type => "string"
    publish :variable => :mset, :type => "string"
    publish :variable => :gpm, :type => "string"
    publish :variable => :device, :type => "string"
    publish :variable => :emul3, :type => "boolean"
    publish :variable => :wheels, :type => "integer"
    publish :variable => :buttons, :type => "integer"
    publish :variable => :name, :type => "string"
    publish :variable => :unique_key, :type => "string"
    publish :function => :Set, :type => "void (string)"
    publish :function => :Restore, :type => "boolean ()"
    publish :function => :Mouse, :type => "void ()"
    publish :function => :Probe, :type => "string ()"
    publish :function => :MakeProposal, :type => "string (boolean, boolean)"
    publish :function => :Found, :type => "boolean ()"
    publish :function => :Selection, :type => "map <string, string> ()"
    publish :function => :Save, :type => "void ()"
  end

  Mouse = MouseClass.new
  Mouse.main
end
