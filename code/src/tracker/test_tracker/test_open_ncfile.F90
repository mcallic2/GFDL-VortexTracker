program test_subroutine_open_ncfile

  use access_subroutines; use netcdf_parms
  implicit none
  include "netcdf.inc"

  character(len=180) :: filename
  integer            :: test_ncid
  integer            :: status

  filename = 'testing_input_data.nc'
  call open_ncfile(filename, test_ncid)
  status = nf_open (filename, nf_nowrite, test_ncid)

  if (status .ne. nf_noerr) then
    write(*,*) "Error opening testing netcdf file"
    error stop
  end if

end program test_subroutine_open_ncfile