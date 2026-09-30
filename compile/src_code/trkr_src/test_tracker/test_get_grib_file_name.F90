!************************************************
!* This test program tests the subroutine get_grib_file_name, which
!* builds the GRIB input file name (and its matching index file name)
!* from the model name, run descriptor, optional storm descriptor,
!* start date, and forecast lead time.
!*
!* Created by: Caitlyn McAllister
!* Email: caitlyn.mcalliser@noaa.gov
!************************************************
program test_subroutine_get_grib_file_name

  use access_subroutines
  use gfilename_info
  use tracked_parms
  use atcf
  use verbose_output

  implicit none

  character(len=120) :: test_gfilename, test_ifilename

  verb = 0

  !----------------------------------------------
  ! test 1: with an optional storm/ATCF descriptor included
  gmodname = 'gfdl'
  rundescr = '6thdeg'
  atcfdescr = 'ike09l'
  allocate(iftotalmins(1))
  iftotalmins(1) = 720
  atcfymdh = 2005082818

  call get_grib_file_name(1, test_gfilename, test_ifilename)

  if (trim(test_gfilename) .ne. 'gfdl.6thdeg.ike09l.2005082818.f00720') &
  then
    write(*,*) "Error in test get_grib_file_name (with descriptor)"
    write(*,*) "Expected gfdl.6thdeg.ike09l.2005082818.f00720 but got " &
               ,trim(test_gfilename)
    error stop
  endif

  if (trim(test_ifilename) .ne. &
      'gfdl.6thdeg.ike09l.2005082818.f00720.ix') then
    write(*,*) "Error in test get_grib_file_name: index file name"
    write(*,*) "Expected gfdl.6thdeg.ike09l.2005082818.f00720.ix" &
               ," but got ", trim(test_ifilename)
    error stop
  endif

  !----------------------------------------------
  ! test 2: without an optional storm/ATCF descriptor
  atcfdescr = ''
  iftotalmins(1) = 0

  call get_grib_file_name(1, test_gfilename, test_ifilename)

  if (trim(test_gfilename) .ne. 'gfdl.6thdeg.2005082818.f00000') then
    write(*,*) "Error in test get_grib_file_name (no descriptor)"
    write(*,*) "Expected gfdl.6thdeg.2005082818.f00000 but got " &
               ,trim(test_gfilename)
    error stop
  endif

end program test_subroutine_get_grib_file_name
