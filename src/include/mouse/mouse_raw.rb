# encoding: utf-8

#  * $Id$
#  * Author: Unknown <yast2-hacker@suse.de>
#    textdomain "mouse"
module Yast
  module MouseMouseRawInclude
    def initialize_mouse_mouse_raw(include_target)
      textdomain "mouse"
    end

    def get_mouse_db
      # map <string, list>
      {
        "00_ps2"   => [
          _("PS/2 mouse (Aux-port)"),
          {
            "mset"   => "PS/2",
            "gpm"    => "ps2",
            "bus"    => "PS/2",
            "device" => "/dev/input/mice",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "01_ms0"   => [
          _("Microsoft compatible serial mouse - (ttyS0 - COM1)"),
          {
            "mset"   => "Microsoft",
            "gpm"    => "ms",
            "device" => "/dev/ttyS0",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "02_ms"    => [
          _("Microsoft compatible serial mouse - (ttyS1 - COM2)"),
          {
            "mset"   => "Microsoft",
            "gpm"    => "ms",
            "device" => "/dev/ttyS1",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "03_ms30"  => [
          _("Microsoft Intellimouse - 3 buttons and wheel - (ttyS0 - COM1)"),
          {
            "mset"   => "IntelliMouse",
            "gpm"    => "ms3",
            "device" => "/dev/ttyS0",
            "emul3"  => false,
            "wheels" => 1
          }
        ],
        "04_ms3"   => [
          _("Microsoft Intellimouse - 3 buttons and wheel - (ttyS1 - COM2)"),
          {
            "mset"   => "IntelliMouse",
            "gpm"    => "ms3",
            "device" => "/dev/ttyS1",
            "emul3"  => false,
            "wheels" => 1
          }
        ],
        "05_msc0"  => [
          _("Mouse Systems serial mouse - (ttyS0 - COM1)"),
          {
            "mset"   => "MouseSystems",
            "gpm"    => "msc",
            "device" => "/dev/ttyS0",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "06_msc"   => [
          _("Mouse Systems serial mouse - (ttyS1 - COM2)"),
          {
            "mset"   => "MouseSystems",
            "gpm"    => "msc",
            "device" => "/dev/ttyS1",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "07_mman0" => [
          _("Mouse Man protocol (serial Logitech mouse) - (ttyS0 - COM1)"),
          {
            "mset"   => "Mouseman",
            "gpm"    => "mman",
            "device" => "/dev/ttyS0",
            "emul3"  => false,
            "wheels" => 0
          }
        ],
        "08_mman"  => [
          _("Mouse Man protocol (serial Logitech mouse) - (ttyS1 - COM2)"),
          {
            "mset"   => "Mouseman",
            "gpm"    => "mman",
            "device" => "/dev/ttyS1",
            "emul3"  => false,
            "wheels" => 0
          }
        ],
        "09_logi0" => [
          _("Old Logitech serial mouse (series 9) - (ttyS0 - COM1)"),
          {
            "mset"   => "Logitech",
            "gpm"    => "logi",
            "device" => "/dev/ttyS0",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "10_logi"  => [
          _("Old Logitech serial mouse (series 9) - (ttyS1 - COM2)"),
          {
            "mset"   => "Logitech",
            "gpm"    => "logi",
            "device" => "/dev/ttyS1",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "11_busm"  => [
          _("Logitech busmouse"),
          {
            "mset"   => "BusMouse",
            "gpm"    => "BusMouse",
            "device" => "/dev/logibm",
            "emul3"  => false,
            "wheels" => 0
          }
        ],
        "12_sun"   => [
          _("Sun Mouse - (/dev/sunmouse)"),
          {
            "mset"   => "MouseSystems",
            "gpm"    => "sun",
            "device" => "/dev/sunmouse",
            "emul3"  => false,
            "wheels" => 0
          }
        ],
        "13_bare0" => [
          _("Oldest 2-button serial mouse - (ttyS0 - COM1)"),
          {
            "mset"   => "Microsoft",
            "gpm"    => "bare",
            "device" => "/dev/ttyS0",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "14_bare"  => [
          _("Oldest 2-button serial mouse - (ttyS1 - COM2)"),
          {
            "mset"   => "Microsoft",
            "gpm"    => "bare",
            "device" => "/dev/ttyS1",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "15_mb"    => [
          _("Microsoft busmouse"),
          {
            "mset"   => "BusMouse",
            "gpm"    => "mb",
            "device" => "/dev/inportbm",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "16_bm"    => [
          _("ATI XL busmouse"),
          {
            "mset"   => "BusMouse",
            "gpm"    => "bm",
            "device" => "/dev/atibm",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "17_pnp0"  => [
          _("Plug-and-Play mice - (ttyS0 - COM1)"),
          {
            "mset"   => "Auto",
            "gpm"    => "pnp",
            "device" => "/dev/ttyS0",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "18_pnp"   => [
          _("Plug-and-Play mice - (ttyS1 - COM2)"),
          {
            "mset"   => "Auto",
            "gpm"    => "pnp",
            "device" => "/dev/ttyS1",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "19_usb"   => [
          _("USB mouse"),
          {
            "mset"   => "PS/2",
            "gpm"    => "ps2",
            "bus"    => "USB",
            "device" => "/dev/input/mice",
            "emul3"  => true,
            "wheels" => 0
          }
        ],
        "20_imps2" => [
          _("Intelli/Wheel mouse (Aux-port)"),
          {
            "mset"   => "imps/2",
            "gpm"    => "imps2",
            "bus"    => "PS/2",
            "device" => "/dev/input/mice",
            "emul3"  => false,
            "wheels" => 1
          }
        ],
        "21_imps2" => [
          _("Intelli/Wheel mouse (USB)"),
          {
            "mset"   => "imps/2",
            "gpm"    => "imps2",
            "bus"    => "USB",
            "device" => "/dev/input/mice",
            "emul3"  => false,
            "wheels" => 1
          }
        ],
        "22_exps2" => [
          _("IntelliMouse Explorer (ps2)"),
          {
            "mset"   => "ExplorerPS/2",
            "gpm"    => "exps2",
            "bus"    => "PS/2",
            "device" => "/dev/input/mice",
            "emul3"  => false,
            "wheels" => 1
          }
        ],
        "23_exps2" => [
          _("IntelliMouse Explorer (USB)"),
          {
            "mset"   => "ExplorerPS/2",
            "gpm"    => "exps2",
            "bus"    => "USB",
            "device" => "/dev/input/mice",
            "emul3"  => false,
            "wheels" => 1
          }
        ],
        "none"     => [
          _("NONE "),
          {
            "mset"   => "",
            "gpm"    => "",
            "device" => "",
            "emul3"  => false,
            "wheels" => 0
          }
        ]
      }
    end
  end
end
