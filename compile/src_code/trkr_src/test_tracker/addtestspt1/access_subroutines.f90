!************************************************
!* Comprehensive Test Runner for all subroutines
!* This module provides access to all subroutines for testing
!*
!* Created by: GitHub Copilot Testing Suite
!************************************************
module access_subroutines
  implicit none
  
  ! Public interface for all tested subroutines
  public :: avgcalc, calc_vmag, calccorr, getcorr, stdevcalc
  public :: wtavrg, wtavrg_lon, getmean, getdiff, getslope
  public :: getyestim, getresid, distbear, bilin_int_uneven
  public :: calcdist, getvrvt, sort_storms_by_pressure, rvcal, barnes
  
end module access_subroutines
