!************************************************
!* This is a REGRESSION test, not a pure unit test (see the header
!* comment in test_getdata_grib.F90 for what that distinction means).
!* It runs read_fhours against a real production lead-times file
!* (test_data/leadtimes.txt, 22 entries, 6-hourly out to 126h) and
!* checks that it parses into the expected hours/minutes arrays.
!*
!* IMPORTANT: read_fhours does not take a filename argument -- it
!* reads from hardcoded Fortran unit 15 with no explicit OPEN
!* statement anywhere in the source, which means it relies entirely
!* on the compiler's default "fort.15" naming convention. In a real
!* run, the run script is responsible for placing (symlinking or
!* copying) the actual lead-times file -- conventionally kept at
!* run/init_data/leadtimes.txt -- at "fort.15" before invoking
!* gettrk.x; the tracker code itself has no idea where that file
!* really lives. This test works around that the same way
!* test_read_nlists.F90 works around read_nlists' hardcoded
!* "namelist.gettrk": it copies the real fixture to a literal
!* "fort.15" in the current working directory at runtime, and will
!* leave that file behind in whatever directory it's run from.
!*
!* A failure here means lead-time parsing behavior changed -- it does
!* not by itself say whether the new behavior is right or wrong; a
!* human needs to judge that and, if the change was intentional,
!* update the expected values below.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_read_fhours

  use access_subroutines
  use tracked_parms
  use verbose_output

  implicit none

#ifndef LEADTIMES_FILE
#define LEADTIMES_FILE "test_data/leadtimes.txt"
#endif

  integer :: test_ifhmax
  integer :: expected_ifhours(22), expected_iftotalmins(22)
  integer :: i

  verb = 0

  call execute_command_line('cp ' // LEADTIMES_FILE // ' ./fort.15')

  call read_fhours(test_ifhmax)

  !----------------------------------------------
  ! test 1: 22 lead times, 6-hourly (360 min apart) from 0 to 126h
  if (test_ifhmax .ne. 22) then
    write(*,*) "Error in test read_fhours: unexpected count"
    write(*,*) "Expected ifhmax=22 but got ", test_ifhmax
    error stop
  endif

  do i = 1, 22
    expected_ifhours(i) = (i-1) * 6
    expected_iftotalmins(i) = (i-1) * 360
  enddo

  if (any(ifhours(1:22) .ne. expected_ifhours) .or. &
      any(iftotalmins(1:22) .ne. expected_iftotalmins)) then
    write(*,*) "Error in test read_fhours: hours/minutes pattern changed"
    write(*,*) "Expected ifhours=", expected_ifhours
    write(*,*) "Got      ifhours=", ifhours(1:22)
    error stop
  endif

  !----------------------------------------------
  ! test 2: every entry in this file falls exactly on the hour, so
  ! ifclockmins (the leftover minutes past the hour) should be zero
  ! throughout, and fhreal (the fractional-hour real value) should
  ! exactly equal ifhours
  if (any(ifclockmins(1:22) .ne. 0)) then
    write(*,*) "Error in test read_fhours: expected all-zero clockmins"
    write(*,*) "Got ifclockmins=", ifclockmins(1:22)
    error stop
  endif

  do i = 1, 22
    if (abs(fhreal(i) - real(expected_ifhours(i))) > 1.0e-5) then
      write(*,*) "Error in test read_fhours: fhreal mismatch at i=", i
      write(*,*) "Expected ", real(expected_ifhours(i)), " but got " &
                 ,fhreal(i)
      error stop
    endif
  enddo

  !----------------------------------------------
  ! test 3: ltix (the lead-time index read from the file's own first
  ! column) should just be 1..22, matching this file's own indexing
  do i = 1, 22
    if (ltix(i) .ne. i) then
      write(*,*) "Error in test read_fhours: ltix mismatch at i=", i
      write(*,*) "Expected ", i, " but got ", ltix(i)
      error stop
    endif
  enddo

end program test_read_fhours
