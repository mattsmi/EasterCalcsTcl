#####
###   Detailed calculations for the date of Easter.
###    Used instead of referring to the epact and Paschal Full Moon tables.
#####

package require Tcl
package provide EasterCalcs 1.0

namespace eval ::MSMelk {
    #This namespace contains all the general calculations
    #   that are necessary for calculations of Easter (Julian, Gregorian, Western, Orthodox, etc.).
    
    set sDAY_TO_ADD  "days"
    set sCAL_WEEKS  "ww"
    set sYEAR  "years"
    set iEDM_JULIAN  1
    set iEDM_ORTHODOX  2
    set iEDM_WESTERN  3
    set iTRIODION_BEGINS -70
    set iPENTECOSTARION_ENDS 56
    set iPENTECOST_SUNDAY 49
    set iGREAT_FAST_BEGINS -48
    # AD 326 is the first valid year for Easter calculations.
    set iFIRST_EASTER_YEAR  326  
    # First year that the Gregorian calendar is valid.
    set iFIRST_VALID_GREGORIAN_YEAR  1583   
    # Last year for which Gregorian calendar is valid.
    set iLAST_VALID_GREGORIAN_YEAR  4099  
    # Dummy date to signal error.
    set dERROR_DATE 9999-01-01
    set sCLOCK_FORMAT "%Y-%m-%d"
    set sCLOCK_ZONE ":UTC"
    
}

proc ::MSMelk::FindJulianCalendarDate {sDate} {
    #Ten days were skipped in the Gregorian calendar from 5 - 14 Oct 1582.
    #This procedure calculates the Julian Calendar date, for any given date
    #   in the Gregorian Calendar.
    
    set dDate 0 

    set ipReturn $::MSMelk::dERROR_DATE
    if {[catch {clock scan $sDate -format $::MSMelk::sCLOCK_FORMAT} dDate]} {
        #Date given in wrong format
        puts stderr "Date not given in correct format (YYYY-MM-DD)"
        return -code 1 $ipReturn
    }
    
    #Calculate the difference in days.
    if {[catch {::MSMelk::CalcDayDiffJulianCal $sDate} iDaysDiff]} {
        return -code 1 "Error calculating the date in the Julian Calendar from: $sDate ."
    }

    #Return the Julian date.
    set dTemp [clock add $dDate [expr -1 * $iDaysDiff] $::MSMelk::sDAY_TO_ADD -timezone $::MSMelk::sCLOCK_ZONE]
    return -code 0 [clock format $dTemp -format $::MSMelk::sCLOCK_FORMAT -timezone $::MSMelk::sCLOCK_ZONE]

}

proc ::MSMelk::CalcDayDiffJulianCal {sDate} {
    
    #Calculates the difference in days to find the Julian Calendar date,
    #   given the Gregorian Calendar date passed in as the argument.
    
    set dBaseGregorianDate 0

    set ipReturn $::MSMelk::dERROR_DATE
    if {[catch {clock scan $sDate -format $::MSMelk::sCLOCK_FORMAT} dDate]} {
        #Date given in wrong format
        puts stderr "Date not given in correct format (YYYY-MM-DD)"
        return -code 1 $ipReturn
    }
    
    #If date before 1582-10-05, just return it, as the Gregorian Calendar was not operative.
    set dDate [clock scan $sDate -format $::MSMelk::sCLOCK_FORMAT -timezone $::MSMelk::sCLOCK_ZONE]
    set dBaseGregorianDate [clock scan "1582-10-05" -format $::MSMelk::sCLOCK_FORMAT -timezone $::MSMelk::sCLOCK_ZONE]
    if {$dDate < $dBaseGregorianDate} {
        return -code 0 0 ;#no difference
    }
    
    #Calculate the difference in days.
    set sYearHundreds [string range $sDate 0 1] ; #The hundreds digits of the year.
    set iFlooredValue [expr floor($sYearHundreds / 4)] ; #We need 1.25 to round to 1, and -1.25 to round to -2.
    return -code 0 [expr int($sYearHundreds - $iFlooredValue - 2)]
    
}

proc ::MSMelk::F09_CalcPreviousEaster {sDate iDateMethod} {

    set dDateHolder ""
    
    set ipReturn $::MSMelk::dERROR_DATE
    if { [catch { clock scan $sDate -format $::MSMelk::sCLOCK_FORMAT } dDate]} {
        #Date given in wrong format
        puts stderr "Date not given in correct format (YYYY-MM-DD)"
        return -code 1 $ipReturn
    }
    if { $iDateMethod < $::MSMelk::iEDM_JULIAN || $iDateMethod > $::MSMelk::iEDM_WESTERN } {
        puts stderr "Dating method of Easter is invalid: $iDateMethod ."
        return -code 1 $ipReturn
    }
    
    set dDateHolder [::MSMelk::F10_CalcEaster [clock format $dDate -format %Y] $iDateMethod ]
    if { $dDateHolder < $dDate } {
        return $dDateHolder
    } else {
        set dYearTemp [clock format [clock add $dDate -1 $::MSMelk::sYEAR] -format %Y]
        set dDateHolder [::MSMelk::F10_CalcEaster $dYearTemp $iDateMethod ]
        return $dDateHolder
    }
        
}

proc ::MSMelk::F11_CalcNextEaster {sDate iDateMethod} {

    set dDateHolder ""

    set ipReturn $::MSMelk::dERROR_DATE
    if {[catch {clock scan $sDate -format $::MSMelk::sCLOCK_FORMAT} dDate]} {
        #Date given in wrong format
        puts stderr "Date not given in correct format (YYYY-MM-DD)"
        return -code 1 $ipReturn
    }
    if {$iDateMethod < $::MSMelk::iEDM_JULIAN || $iDateMethod > $::MSMelk::iEDM_WESTERN} {
        return -code 1 $ipReturn
    }
    
    set dDateHolder [::MSMelk::F10_CalcEaster [clock format $dDate -format %Y] $iDateMethod]
    if {$dDateHolder > $dDate} {
        return $dDateHolder
    } else {
        set dYearTemp [clock format [clock add $dDate +1 $::MSMelk::sYEAR] -format %Y]
        set dDateHolder [::MSMelk::F10_CalcEaster $dYearTemp $iDateMethod]
        return $dDateHolder
    }
       
}

proc ::MSMelk::F10_CalcEaster {iYear  iDateMethod} {
# ******************************************************
# *** Calculations from: http://users.sa.chariot.net.au/~gmarts/eastalg.htm .
# ******************************************************

    set dDate ""
    
    set ipReturn $::MSMelk::dERROR_DATE
    if { $iDateMethod < $::MSMelk::iEDM_JULIAN || $iDateMethod > $::MSMelk::iEDM_WESTERN } {
        return -code 1 $ipReturn
    }
    if { $iYear < $::MSMelk::iFIRST_EASTER_YEAR || $iYear > $::MSMelk::iLAST_VALID_GREGORIAN_YEAR } {
        return -code 1 $ipReturn
    }
    
    
    set dDate [::MSMelk::F15_CalcDateOfEaster $iYear $iDateMethod]
    return $dDate
    
}

proc ::MSMelk::F15_CalcDateOfEaster {imYear imMethod} {
# ******************************************************
#  EASTER SUNDAY DATE CALCULATION

#  This procedure returns Easter Sunday day and month
#  for a specified year and method.

#  Inputs:
#   imYear is the specified year
#   imMethod is 1, 2 or 3 as detailed below

#  Outputs
#  imDay & imMonth are the returned day and month


# ====================================================

#  The Gregorian calendar has gradually been adopted world
#  wide over from October 1582.  The last known use of the
#  Julian calendar by the author was in Greece in 1923.
#  Either at the time of the calendar change or at a later
#  date, some (but not all) regions have used a revised
#  Easter date calculation based on the Gregorian calendar.
#  The Gregorian calendar is valid until 4099.

#  As a result, the 3 possible methods are:
#  1. The original calculation based on the Julian calendar
#  2. The original calculation, with the Julian date
#     converted to the equivalent Gregorian date
#  3. The revised calculation based on the Gregorian calendar

#  Most Western churches moved from method 1 to method 3 at
#  the adoption of the Gregorian calendar, while most
#  Orthodox churches moved from method 1 to method 2.

#  Here is a guide on which method to use.  It is important
#  to check the history of the region in question to find the
#  correct date of their change from Julian to Gregorian
#  calendars, and if applicable, their change from the
#  original to revised Easter Sunday date calculation.

#  AUSTRALIA
#    Has used the Gregorian calendar since settlement
#    Western churches & public holidays use method 3
#    Orthodox churches use method 2

#  EUROPE
#    For years 326 to 1582, use method 1
#    What was then Italy changed calendar AND calculation
#    method in October 1582, so for years 1583 to 4099,
#    use method 3.  Most mainland European regions had
#    converted to the Gregorian calendar by 1700

#  ENGLAND
#    For years 326 to 1752, use method 1
#    Adopted the Gregorian calendar in September 1752
#    Use method 3 for Western churches for years 1753 to 4099
#    Use method 2 for Orthodox churches for years 1753 to 4099

#  AMERICA
#    Use method 1 from 326 AD until changes as follows:
#    Regions of America under French influence adopted the
#    Gregorian calendar in October 1582, while regions
#    under British influence adopted both the new calendar
#    and calculation from September 1752.
#    Use method 2 for Orthodox churches after the adoption
#    of the Gregorian calendar.
#    Use method 3 for Western churches after the adoption
#    of the Gregorian calendar.

# ======================================================

# Method 1: ORIGINAL CALCULATION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  From 326 AD, Easter Sunday was determined as the
#  Sunday following the Paschal Full Moon (PFM) date
#  for the given year based on the Julian Calendar.  PFM dates
#  were made up of a simple cycle of 19 Julian calendar
#  dates.  This method returns a Julian calendar date,
#  and applies for all years from 326.

# Method 2: ORIGINAL CALCULATION converted to GREGORIAN CALENDAR
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Same (original) calculation, also converts the Julian
#  calendar date to the equivalent Gregorian calendar date.
#  It applies for years 1583 to 4099.  This method
#  is currently used by almost all Eastern Orthodox Churches.

# Method 3: REVISED CALCULATION
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  This method calculates Easter Sunday as the Sunday
#  following the Paschal Full Moon (PFM) date for the
#  year based on the Gregorian Calendar.  PFM dates are
#  calculated from the relationship between the sun,
#  the moon, and the earth (as understood in 1582), using many 19
#  Gregorian calendar date cycles.   This method was
#  adopted from 1583 in Europe, 1753 in England and is
#  currently used by Western churches.
# ================================================

#  Validate arguments
#  imYear and imMethod are both integers.
# ******************************************************

    # default values for invalid arguments
    set imDay 0
    set imMonth 0
    # intermediate results (all integers)
    set iFirstDig 0
    set iRemain19 0
    set iTempNum 0
    # tables A to E results (all integers)
    set iTableA 0
    set iTableB 0
    set iTableC 0
    set iTableD 0
    set iTableE 0
    
    
    # Set up default values
    set ipReturn $::MSMelk::dERROR_DATE

    # Validate arguments
    if {$imMethod < $::MSMelk::iEDM_JULIAN || $imMethod > $::MSMelk::iEDM_WESTERN} {
        puts stderr "Method must be iEDM_JULIAN, iEDM_ORTHODOX or iEDM_WESTERN"
        return -code 1 $ipReturn
    } elseif {$imMethod == $::MSMelk::iEDM_JULIAN && $imYear < $::MSMelk::iFIRST_EASTER_YEAR} {
        puts stderr "The original calculation applies to all years from AD"
        return -code 1 $ipReturn
    } elseif {($imMethod == $::MSMelk::iEDM_ORTHODOX || $imMethod == $::MSMelk::iEDM_WESTERN) && (($imYear < $::MSMelk::iFIRST_VALID_GREGORIAN_YEAR) || ($imYear > $::MSMelk::iLAST_VALID_GREGORIAN_YEAR))} {
        puts stderr "Gregorian calendar Easters apply for years $::MSMelk::iFIRST_VALID_GREGORIAN_YEAR to $::MSMelk::iLAST_VALID_GREGORIAN_YEAR only."
        return -code 1 $ipReturn
    } else {
        #OK to proceed
    }
    
    #  Calculate Easter Sunday date
    # first 2 digits of year (integer division)
    set iFirstDig [expr $imYear / 100]
    # remainder of year / 19
    set iRemain19 [expr $imYear % 19]
    
    if {($imMethod == $::MSMelk::iEDM_JULIAN) || ($imMethod == $::MSMelk::iEDM_ORTHODOX)} {
        #  calculate PFM date
        set iTableA [expr ((225 - 11 * $iRemain19) % 30) + 21]

        #  find the next Sunday
        set iTableB [expr ($iTableA - 19) % 7]
        set iTableC [expr (40 - $iFirstDig) % 7]

        set iTempNum [expr $imYear % 100 ]
        set iTableD [expr ($iTempNum + $iTempNum / 4) % 7]

        set iTableE [expr ((20 - $iTableB - $iTableC - $iTableD) % 7) + 1]
        set imDay [expr $iTableA + $iTableE]
        
        # convert Julian to Gregorian date
        if {$imMethod == $::MSMelk::iEDM_ORTHODOX} {
           # 10 days were # skipped#  in the Gregorian calendar from 5-14 Oct 1582
            set iTempNum  10
            # Only 1 in every 4 century years are leap years in the Gregorian
            # calendar (every century is a leap year in the Julian calendar)
            if { $imYear > 1600 } {
                set iTempNum [expr $iTempNum + $iFirstDig - 16 - (($iFirstDig - 16) / 4)]
            }
            set imDay [expr $imDay + $iTempNum]
            
        }
        
    } elseif {$imMethod == $::MSMelk::iEDM_WESTERN} {
        #  calculate PFM date
        set iTempNum [expr ($iFirstDig - 15) / 2 + 202 - 11 * $iRemain19]
        switch $iFirstDig {
            21 -
            24 -
            25 -
            27 -
            28 -
            29 -
            30 -
            31 -
            32 -
            34 -
            35 -
            38 { set iTempNum [expr $iTempNum - 1] }
            33 -
            36 -
            37 -
            39 -
            40 { set iTempNum [expr $iTempNum - 2] }
        }
        set iTempNum [expr $iTempNum % 30]

        set iTableA  [expr $iTempNum + 21]
        if {$iTempNum == 29} {
            set iTableA [expr $iTableA - 1]
        }
        if {(($iTempNum == 28) && ($iRemain19 > 10))} {
            set iTableA [expr $iTableA - 1]
        }

        #  find the next Sunday
        set iTableB [expr ($iTableA - 19) % 7]

        set iTableC [expr (40 - $iFirstDig) % 4]
        if {$iTableC == 3} {
            set iTableC [expr $iTableC + 1]
        }
        if {$iTableC > 1} {
            set iTableC [expr $iTableC + 1]
        }

        set iTempNum [expr $imYear % 100]
        set iTableD [expr ($iTempNum + $iTempNum / 4) % 7]

        set iTableE [expr ((20 - $iTableB - $iTableC - $iTableD) % 7) + 1]
        set imDay [expr $iTableA + $iTableE]
        
    }
    
    #  return the date
    if {$imDay > 61} {
        set imDay [expr $imDay - 61]
        set imMonth 5
        # for imMethod 2, Easter Sunday can occur in May
    } elseif {$imDay > 31} {
        set imDay [expr $imDay - 31]
        set imMonth 4
    } else {
        set imMonth 3
    }
    # set up date field
    set sDate $imYear
    append sDate "-" $imMonth "-" $imDay
    set dDate [clock scan $sDate -format $::MSMelk::sCLOCK_FORMAT -timezone $::MSMelk::sCLOCK_ZONE]

    return $dDate
    
}      

