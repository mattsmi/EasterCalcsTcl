#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec wish "$0" ${1+"$@"}

###   Easter Calculator returns the Julian and Gregorian dates of Easter for a given year.
#     Copyright (C) 2014  Matthew Smith
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
###

package require Tk
package require EasterCalcs
package provide CalcEaster 1.0

namespace eval ::MSMelk  {
    
    set sOrthodoxDate ""
    set sWesternDate ""
    set sJulianDate ""
    set sTodayGregorian [clock format [clock seconds] -format $::MSMelk::sCLOCK_FORMAT -timezone $::MSMelk::sCLOCK_ZONE]
    set sTodayJulian [::MSMelk::FindJulianCalendarDate $sTodayGregorian]
    set sTodayGregorian [clock format [clock scan $sTodayGregorian -format $::MSMelk::sCLOCK_FORMAT -timezone $::MSMelk::sCLOCK_ZONE] -format {%d %B %Y} -locale current]
    set sTodayJulian [clock format [clock scan $sTodayJulian -format $::MSMelk::sCLOCK_FORMAT -timezone $::MSMelk::sCLOCK_ZONE] -format {%d %B %Y} -locale current]
}
proc ::MSMelk::CalcEaster { sYear } {
    
    set sErrorMsg "N/A"
    #Check that valid date has been returned
   if { [catch { clock scan $sYear -format {%Y} } dYear]} {
        #Date given in wrong format
        puts stderr "Date not given in correct format (YYYY)"
        set ::MSMelk::sWesternDate $sErrorMsg
        set ::MSMelk::sOrthodoxDate $sErrorMsg
        set ::MSMelk::sJulianDate $sErrorMsg
        #exit 1
    } else {
        set dYear $sYear
        
        if {[catch {::MSMelk::F10_CalcEaster $dYear 3} sWestern]} {
            set ::MSMelk::sWesternDate $sErrorMsg
        } else {
            set ::MSMelk::sWesternDate [clock format $sWestern -format {%d %B %Y} -locale current]
        }
        if {[catch {::MSMelk::F10_CalcEaster $dYear 2} sOrthodox]} {
            set ::MSMelk::sOrthodoxDate $sErrorMsg
        } else {
            set ::MSMelk::sOrthodoxDate [clock format $sOrthodox -format {%d %B %Y} -locale current]
        }
        if {[catch {::MSMelk::F10_CalcEaster $dYear 1} sJulian]} {
            set ::MSMelk::sJulianDate $sErrorMsg
        } else {
            set ::MSMelk::sJulianDate [clock format $sJulian -format {%d %B %Y} -locale current]
        }
    }
}
proc ::MSMelk::pSetUpWindow {} {
    
    #We do not want the extra window, so assign widgets to the window "." .
    set wWin [winfo name .]
    label  .l  -text "Easter Dates" -font {-family "\"Sans Serif\"" -size 14 -weight bold}
        pack .l  -expand 1    -fill both

    button .bCalc -text "Calculate" -default active  -font {-family "\"Sans Serif\"" -size 10 -weight bold} \
            -command "::MSMelk::CalcEaster \$sYear"
    button .bOk -text "Close"  -font {-family "\"Sans Serif\"" -size 10 -weight bold} -command {destroy .} 
    
    #Set up the Field to enter a year
    set sCurrentYear [clock format [clock seconds] -format %Y]
    frame .year
    label .year.label -text "Year:" -width 13 -anchor w -font {-family "\"Serif\"" -size 10 -slant roman}
    entry .year.entry -width 4 -textvariable sYear -font {-family "\"Serif\"" -size 10 -slant roman}
    pack .year.label .year.entry -side left
    bind .year.entry <Return> "
        ::MSMelk::CalcEaster \$sYear
        focus .year.entry
    "
    #Default to current year
    .year.entry insert 0 $sCurrentYear
    focus .bCalc
    pack .year  -side top -fill x
    
    #Area for the two Dates of Easter
    frame .pashxo -relief raised -borderwidth 3 -background "darkgray"
        frame .pashxo.western
        label .pashxo.western.label -text "Western Easter:" -width 25 -anchor w -font {-family "\"Serif\"" -size 10 -slant roman}
        label .pashxo.western.data -text "" -width 20 -textvariable ::MSMelk::sWesternDate -font {-family "\"Serif\"" -size 10 -slant roman}
        pack .pashxo.western.label .pashxo.western.data -side left
        frame .pashxo.orthodox
        label .pashxo.orthodox.label -text "Orthodox Easter:" -width 25 -anchor w -font {-family "\"Serif\"" -size 10 -slant roman}
        label .pashxo.orthodox.data -text "" -width 20 -textvariable ::MSMelk::sOrthodoxDate -font {-family "\"Serif\"" -size 10 -slant roman}
        pack .pashxo.orthodox.label .pashxo.orthodox.data -side left
        frame .pashxo.julian
        label .pashxo.julian.label -text "Julian Easter:" -width 25 -anchor w -font {-family "\"Serif\"" -size 10 -slant roman}
        label .pashxo.julian.data -text "" -width 20 -textvariable ::MSMelk::sJulianDate -font {-family "\"Serif\"" -size 10 -slant roman}
        pack .pashxo.julian.label .pashxo.julian.data -side left
        # put them in.
        pack .pashxo.western
        pack .pashxo.orthodox
        pack .pashxo.julian
    frame .hodiau -relief sunken -borderwidth 1 -background "lightgreen"
        frame .hodiau.todayGregorian
        label .hodiau.todayGregorian.label -text "Today (UTC in Gregorian):" -width 25 -anchor w -font {-family "\"Serif\"" -size 8 -slant italic}
        label .hodiau.todayGregorian.data -text "" -width 20 -textvariable ::MSMelk::sTodayGregorian -font {-family "\"Serif\"" -size 8 -slant italic}
        pack .hodiau.todayGregorian.label .hodiau.todayGregorian.data -side left    
        frame .hodiau.todayJulian
        label .hodiau.todayJulian.label -text "Today (UTC in Julian):" -width 25 -anchor w -font {-family "\"Serif\"" -size 8 -slant italic}
        label .hodiau.todayJulian.data -text "" -width 20 -textvariable ::MSMelk::sTodayJulian -font {-family "\"Serif\"" -size 8 -slant italic}
        pack .hodiau.todayJulian.label .hodiau.todayJulian.data -side left
        # put them in.
        pack .hodiau.todayGregorian
        pack .hodiau.todayJulian
    #Pack the all together on the screen.
    pack .pashxo -padx 2 -pady 3
    pack .hodiau -padx 2 -pady 2

    #Bottom buttons
    pack .bCalc  -side right
    pack .bOk -side left
    
    # Now set the widget up as a centred dialogue.
    # But first, we need the geometry managers to finish setting
    # up the interior of the dialogue, for which we need to run the
    # event loop with the widget hidden completely...
    wm withdraw .
    update
    set x [expr {([winfo screenwidth .]-[winfo width .])/2}]
    set y [expr {([winfo screenheight .]-[winfo height .])/2}]
    wm geometry  . +$x+$y
    #wm transient . .
    wm title     . "Easter Date calculation"
    wm deiconify .
    
}


#Script starts here
::MSMelk::pSetUpWindow