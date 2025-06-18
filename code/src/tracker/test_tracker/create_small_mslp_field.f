      module trig_vals
        real, save :: pi, dtr
        real, save :: dtk = 111.1949     ! Dist (km) over 1 deg lat
                                         ! using erad=6371.0e+3
        real, save :: erad = 6371.0e+3   ! Earth's radius (m)
        real, save :: ecircum = 40030.2  ! Earth's circumference
                                         ! (km) using erad=6371.e3
        real, save :: omega = 7.292e-5
      end module trig_vals

c     ------------------------------------------------------------------
c   
c     ------------------------------------------------------------------
      program create_mslp

c     This program creates a field of mslp values and writes them out
c     to a flat binary file to be readable by GrADS.  Note that the 
c     longitudes in this file will start west and go east, and the 
c     latitudes will start north and go south.
c
c     imax integer max range of ylat array
c     jmax integer max range of xlon array
c     dx real increment in x-direction
c     dy real increment in y-direction
c     xstartlon real westernmost longitude
c     ystartlat real northernmost latitude

      USE trig_vals

      implicit none

      integer, parameter :: imax=11, jmax=11
      integer :: irem,jrem
      real :: xstartlon,ystartlat
      real :: dx,dy
      real :: xlon(imax),ylat(jmax),xmslp(imax,jmax)

c     ------

      pi = 4. * atan(1.)   ! Both pi and dtr were declared in module 
      dtr = pi/180.0       ! trig_vals, but were not yet defined.
  
      xlon = -999.0  ! initialize array
      ylat = -999.0  ! initialize array

      dx = 1.00  ! grid spacing in i-direction
      dy = 1.00  ! grid spacing in j-direction

      xstartlon = 275.0  ! westernmost lon of our grid
      ystartlat =  50.0  ! northernmost lat of our grid

      ! Test to ensure imax and jmax are odd....

      irem = mod(imax,2)
      jrem = mod(jmax,2)

      if (irem == 0 .or. jrem == 0) then
        print *,'ERROR: imax & jmax need to be odd and they are not.'
        print *,'  imax= ',imax,' jmax= ',jmax
        stop 95
      endif

      call generate_lats_lons (imax,jmax,xlon,ylat,dx,dy
     &         ,xstartlon,ystartlat)

      call generate_mslp_field (imax,jmax,xlon,ylat,dx,dy
     &         ,xstartlon,ystartlat,xmslp)
     &                         

      ! This next routine writes the data out in direct binary format,
      ! which is needed for GrADS to plot it.  If you are using 
      ! something different to read and/or plot the data (i.e., python),
      ! you may need to adjust the output in that routine.

      call write_grads_output (imax,jmax,xmslp)

      stop
      end

c     ------------------------------------------------------------------
c
c     ------------------------------------------------------------------
      subroutine generate_lats_lons (imax,jmax,xlon,ylat,dx,dy
     &                              ,xstartlon,ystartlat)
c
c     This subroutine fills in the values for the longitudes and
c     latitudes.

      implicit none

      integer, intent(in) :: imax,jmax
      integer             :: i,j
      real, intent(in)    :: xstartlon,ystartlat,dx,dy
      real, intent(inout) :: xlon(imax),ylat(jmax)

      do i = 1,imax
        xlon(i) = xstartlon + ((i-1) * dx)
        do j = 1,jmax
          ylat(j) = ystartlat - ((j-1) * dy )
c          print *,'gll i= ',i,' j= ',j,' xlon= ',xlon(i)
c     &           ,' ylat= ',ylat(j)
        enddo
      enddo
c
      return
      end

c     ------------------------------------------------------------------
c
c     ------------------------------------------------------------------
      subroutine generate_mslp_field (imax,jmax,xlon,ylat,dx,dy
     &                               ,xstartlon,ystartlat,xmslp)
c
c     This subroutine creates a field of mslp values with a center low
c     that fades out to higher values away from the center.

      implicit none

      integer, intent(in) :: imax,jmax
      integer             :: i,j,nincr,iix,jix,icen,jcen
      real, intent(in)    :: xstartlon,ystartlat,dx,dy
      real, intent(inout) :: xlon(imax),ylat(jmax),xmslp(imax,jmax)
      real                :: xmslp_center,xincr,efold,dist,degrees
      real                :: wt,efoldsq,xmslp_outer

      efold   = 100.0  ! e-folding distance for weighting
      efoldsq = efold**2

      ! Set the value for the minimum MSLP at the center of the "storm"
      ! and the max MSLP at the periphery of the "storm".

      xmslp_center =  98500.0
      xmslp_outer  = 101300.0

      ! Set the number of points to increment to either side of the
      ! grid center point in the subsequent loop.

      xincr = float(imax-1) / 2.0
      nincr = int(xincr)

      ! Set the indices for the center point, and then set its mslp
      ! value to the value specified above with xmslp_center.

      icen = nincr + 1
      jcen = nincr + 1

      xmslp(icen,jcen) = xmslp_center

      jix = 0

      jloop: do j = -nincr,nincr

        jix = jix + 1
        iix = 0

        iloop: do i = -nincr,nincr

          iix = iix + 1

c          print *,' '
c          print *,'--------------------- '
c          print *,'before calcdist, jix= ',jix,' iix= ',iix,' xlon= '
c     &           ,xlon(iix),' ylat= ',ylat(jix),' xlon_icen= '
c     &           ,xlon(icen),' ylat_jcen= ',ylat(jcen)

          call calcdist(xlon(iix),ylat(jix),xlon(icen),ylat(jcen)
     &                 ,dist,degrees)

c          print *,'after calcdist, dist= ',dist,' degrees= ',degrees
c     &           ,' efoldsq= ',efoldsq,' wt arg = '
c     &           ,-1.0*dist*dist/efoldsq

          wt = exp(-1.0*dist*dist/efoldsq)

          xmslp(iix,jix) = xmslp_center + ((xmslp_outer - xmslp_center)
     &                                     * (1.0-wt))

c          write (6,91) j,i,jix,iix,wt,xmslp(iix,jix)

        enddo iloop

      enddo jloop 

  91  format (1x,'j= ',i4,' i= ',i4,' jix= ',i4,' iix= ',i4
     &       ,' wt= ',f7.5,' xmslp(iix,jix)= ',f11.4)

      return
      end

c     ------------------------------------------------------------------
c
c     ------------------------------------------------------------------
      subroutine calcdist(rlonb,rlatb,rlonc,rlatc,xdist,degrees)
c
c     ABSTRACT: This subroutine computes the distance between two 
c               lat/lon points by using spherical coordinates to 
c               calculate the great circle distance between the points.
c                       Figure out the angle (a) between pt.B and pt.C,
c             N. Pole   then figure out how much of a % of a great 
c               x       circle distance that angle represents.
c              / \
c            b/   \     cos(a) = (cos b)(cos c) + (sin b)(sin c)(cos A)
c            /     \                                             
c        pt./<--A-->\c     NOTE: The latitude arguments passed to the
c        B /         \           subr are the actual lat vals, but in
c                     \          the calculation we use 90-lat.
c               a      \                                      
c                       \pt.  NOTE: You may get strange results if you:
c                         C    (1) use positive values for SH lats AND
c                              you try computing distances across the 
c                              equator, or (2) use lon values of 0 to
c                              -180 for WH lons AND you try computing
c                              distances across the 180E meridian.
c    
c     NOTE: In the diagram above, (a) is the angle between pt. B and
c     pt. C (with pt. x as the vertex), and (A) is the difference in
c     longitude (in degrees, absolute value) between pt. B and pt. C.
c
c     !!! NOTE !!! -- THE PARAMETER ecircum IS DEFINED (AS OF THE 
c     ORIGINAL WRITING OF THIS SYSTEM) IN KM, NOT M, SO BE AWARE THAT
c     THE DISTANCE RETURNED FROM THIS SUBROUTINE IS ALSO IN KM.
c
c     20 May 2022: After all these years with the  tracker, I uncovered
c     a bug in this distance calculation.  For points that are 
c     extremely close to each other, inverse cosine function would 
c     return a value of zero because of truncation due to using single
c     precision.  I had to switch to using double precision and also 
c     using the double-precision versions of sin & cos (dsin & dcos).
c
      USE trig_vals

      implicit none

      integer, parameter  :: dp = selected_real_kind(12, 60)
      real rlonb,rlatb,rlonc,rlatc,xdist,degrees
      real (dp) :: difflon8,distlatb8,distlatc8,pole8,degrees8,xdist8
      real (dp) :: rlonb8,rlatb8,rlonc8,rlatc8,cosanga,circ_fract
c
      rlonb8 = rlonb
      rlatb8 = rlatb
      rlonc8 = rlonc
      rlatc8 = rlatc

      if (rlatb8 < 0.0 .or. rlatc8 < 0.0) then
        pole8 = -90.
      else
        pole8 = 90.
      endif
c
      distlatb8 = (pole8 - rlatb8) * dtr
      distlatc8 = (pole8 - rlatc8) * dtr
      difflon8  = abs( (rlonb8 - rlonc8)*dtr )
c
      cosanga = ( dcos(distlatb8) * dcos(distlatc8) +
     &            dsin(distlatb8) * dsin(distlatc8) * dcos(difflon8))

c     This next check of cosanga is needed since I have had ACOS crash
c     when calculating the distance between 2 identical points (should
c     = 0), but the input for ACOS was just slightly over 1
c     (e.g., 1.00000000007), due to (I'm guessing) rounding errors.

      if (cosanga > 1.0) then
        cosanga = 1.0
      endif

      degrees8    = dacos(cosanga) / dtr
      circ_fract  = degrees8 / 360.
      xdist8      = circ_fract * ecircum

      xdist   = xdist8
      degrees = degrees8
c
c     NOTE: whether this subroutine returns the value of the distance
c           in km or m depends on the scale of the parameter ecircum. 
c           At the original writing of this subroutine (7/97), ecircum
c           was given in km.
c
      return
      end

c     ------------------------------------------------------------------
c
c     ------------------------------------------------------------------
      subroutine write_grads_output (imax,jmax,xmslp)
c
c     This routine writes an array out to a file in the direct binary 
c     format that GrADS requires.  The record length is specified and
c     will vary depending on whether you have compiled with 4-byte or
c     8-byte reals.

      implicit none

      character*75 :: outfile,out_txt_file
      real, intent(in) :: xmslp(imax,jmax)
      integer, parameter :: iunit=51,iformunit=53
      integer, intent(in) :: imax,jmax
      integer :: ios
      integer :: irec,i,j

      outfile = 'mslp_sample_file.dat'
      out_txt_file = 'mslp_sample_file.txt'

      ! Write out data to direct binary file

      open (unit=iunit,file=outfile,access='direct',form='unformatted'
     &             ,status='replace',recl=imax*jmax)

      irec = 1

      write (iunit,rec=irec) ((xmslp(i,j),i=1,imax),j=1,jmax)

      close (iunit)

      ! Write out data to formatted text file

      open (unit=iformunit,file=out_txt_file,status='unknown'
     &     ,iostat=ios)

      do i = 1,imax
        write (iformunit,91) (xmslp(i,j),j=1,jmax)
      enddo

   91 format (11(1x,f8.1))

      close (iformunit)

      return
      end
