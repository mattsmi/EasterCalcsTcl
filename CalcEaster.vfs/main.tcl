#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}
package require Tcl
package require starkit
if  {[starkit::startup] ne "sourced"} {
     ::tcl::tm::path add [file join $starkit::topdir libmodule] 
	 package require CalcEaster 
}
