program test_get_netcdf_real_type
  
  use access_subroutines; use tracked_parms; use verbose_output; use netcdf_parms

  implicit none
  include "netcdf.inc"

  !subroutine get_netcdf_real_type (ncid,var3_name,xtype,ignrret)
  !INPUT:
  !ncid   integer that contains the NetCDF file ID
  !var3_name  character name of NetCDF input variable
  !OUTPUT:
  !xtype  integer value that indicates 4-byte or 8-byte real. A value of 5 = 4-byte real;  6 = 8-byte real.
  !ignrret integer return code from this routine

  ! examples of calls to get_netcdf_real_type
  !   in routine getdata_netcdf:
  !   call get_netcdf_real_type (nc_lsmask_file_id,chparm(ip),xtype,ignrret)
  !
  !   in routine getgridinfo_netcdf:
  !   call get_netcdf_real_type (ncfile_id,netcdfinfo%lon_name,xtype,ignrret)
  !
  !   in routine read_netcdf_hours:
  !         call get_netcdf_real_type (ncfile_id,netcdfinfo%time_name,xtype,ignrret)



  integer   :: ncid
  integer   :: xtype
  integer   :: ignrret
  character :: var3_name




end program test_get_netcdf_real_type