!-------------------------------------------------------------------------
! Module containing settings and options relating to renderings
! includes default values of these options and submenu for changing them
!-------------------------------------------------------------------------
module settings_render
 use colourbar, only:ColourBarDisp,iplotcolourbarlabel
 use labels, only:lenlabel
 implicit none
 integer :: ncontours,npix,icolours,iColourBarStyle
 logical :: iplotcont_nomulti,ilabelcont
 logical :: icolour_particles,inormalise_interpolations
 logical :: ifastrender,idensityweightedinterpolation
 character(len=lenlabel+20) :: projlabelformat
 integer :: iapplyprojformat

 namelist /renderopts/ npix,icolours,ncontours,iplotcont_nomulti, &
   icolour_particles,ColourBarDisp,inormalise_interpolations, &
   ifastrender,idensityweightedinterpolation,iColourBarStyle, &
   iplotcolourbarlabel,ilabelcont,projlabelformat,iapplyprojformat

contains

!---------------------------------------------
! set default values for these options
!---------------------------------------------
subroutine defaults_set_render
  implicit none

  icolours = 2               ! colour scheme to use
  npix = 0                 ! pixels in x direction for rendering
  iColourBarStyle = 1        ! whether or not to plot the colour bar and style
  iplotcont_nomulti = .false. ! plot contours
  icolour_particles = .false. ! colour particles instead of using pixels
  ncontours = 30             ! number of contours to plot
  ColourBarDisp = 5.0 ! displacement of colour bar label from edge
  inormalise_interpolations = .false.       ! do not normalise interpolations
  ifastrender = .false. ! use accelerated rendering
  idensityweightedinterpolation = .false.
  iplotcolourbarlabel = .true.
  ilabelcont = .false.   ! print numeric labels on contours
  projlabelformat = ' '
  iapplyprojformat = 0

  return
end subroutine defaults_set_render

!-----------------------------------------------------------------------------
! options for rendered plots
!-----------------------------------------------------------------------------
subroutine submenu_render(ichoose)
  use colourbar, only:maxcolourbarstyles,labelcolourbarstyles,barisvertical
  use colours, only:schemename,ncolourschemes,colour_demo
  use prompting, only:prompt,print_logical
  use params, only:maxplot
  implicit none
  integer, intent(in) :: ichoose
  character(len=5) :: string
  integer :: ians,i,ierr,icolourprev
!
!--rendering options
!
  ians = ichoose
  print "(a)",'----------------- rendering options -------------------'
  
  if (ians.le.0 .or. ians.gt.8) then
     if (npix.gt.0) then
        write(string,"(i5)") npix
     else
        string = 'AUTO'
     endif
     print 10,trim(string),icolours,print_logical(iplotcont_nomulti),ncontours, &
           iColourBarStyle,print_logical(icolour_particles), &
           print_logical(inormalise_interpolations),print_logical(ifastrender),&
           print_logical(idensityweightedinterpolation),trim(projlabelformat)
10   format( &
          ' 0) exit ',/,                      &
          ' 1) set number of pixels               ( ',a,' )',/, &
          ' 2) change colour scheme               (',i2,' )',/,    &
          ' 3) contour plotting prompt on/off     ( ',a,' )',/, &
          ' 4) change number of contours          (',i3,' )',/, &
          ' 5) colour bar options                 ( ',i2,' )',/,&
          ' 6) use particle colours not pixels    ( ',a,' )',/,& 
          ' 7) normalise interpolations           ( ',a,' )',/,&
          ' 8) use accelerated rendering          ( ',a,' )',/,&
          ' 9) use density weighted interpolation ( ',a,' )',/, &
          ' 10) customize label on projection plots ( ',a,' )')
     call prompt('enter option',ians,0,10)
  endif
!
!--options
!
 select case(ians)
!------------------------------------------------------------------------
    case(1)
       print "(5(/,a),/)",' Note: setting number of pixels = 0 means that ', &
                        '       the number of pixels will be automatically ', &
                        '       chosen to match the device used for plotting.', &
                        '       The number of pixels is then determined by ', &
                        '       the page size (set in the p)age menu).'
       call prompt('enter number of pixels along x axis (0=auto)',npix,0,10000)
!------------------------------------------------------------------------
    case(2)
       ierr = 1
       icolourprev = icolours
       write(*,"(i2,a,1x)") (i,': '//trim(schemename(i)),i=1,ncolourschemes)
       write(*,"(i2,a,1x)") ncolourschemes+1,': demo plot of all schemes'
       print "(a)",'(-ve = inverse, 0 = contours only)'
       promptloop: do while (ierr /= 0)
          call prompt('enter colour scheme for rendering ',icolours,-ncolourschemes,ncolourschemes+1)
          !
          ! demonstration plot of all colour schemes
          !      
          ierr = 0
          if (abs(icolours).eq.ncolourschemes+1) then
             call colour_demo
             icolours = icolourprev
             ierr = 1
          endif
       enddo promptloop
!------------------------------------------------------------------------
    case(3)
       if (icolours.eq.0) then
          print "(2(/,a),/)",' Warning: this option has no effect if colour scheme 0 is set', &
                             '          (cannot plot contours on top of contours)'
       endif
       call prompt(' allow contour plotting prompt?',iplotcont_nomulti)
       print "(a)",' Contour plotting prompt is '//trim(print_logical(iplotcont_nomulti))
       if (iplotcont_nomulti .or. icolours.eq.0) then
          call prompt(' enter number of contours between min,max',ncontours,0,500)
          call prompt(' plot numeric labels on contours? ',ilabelcont)
       endif
!------------------------------------------------------------------------
    case(4)
       call prompt(' enter number of contours between min,max',ncontours,0,500)
       call prompt(' plot numeric labels on contours? ',ilabelcont)
!------------------------------------------------------------------------
    case(5)
       do i=0,maxcolourbarstyles
          print "(1x,i1,')',1x,a)",i,trim(labelcolourbarstyles(i))
       enddo
       call prompt(' enter colour bar style to use ',iColourBarStyle,0,maxcolourbarstyles)
       print "(a,/)",'colour bar style = '//trim(labelcolourbarstyles(iColourBarStyle))
       
       if (iColourBarStyle.gt.0) then
          call prompt(' plot colour bar label?',iplotcolourbarlabel)
          if (barisvertical(iColourBarStyle) .and. iplotcolourbarlabel) then
             call prompt(' enter displacement of text from edge (character heights) ', &
                         ColourBarDisp)
          endif
       endif
!------------------------------------------------------------------------
    case(6)
       icolour_particles = .not.icolour_particles
       print "(a)",' Use particle colours instead of pixels is ' &
                   //trim(print_logical(icolour_particles))
!------------------------------------------------------------------------
    case(7)
       inormalise_interpolations = .not.inormalise_interpolations
       print "(a)",' Normalisation of interpolations is ' &
                   //trim(print_logical(inormalise_interpolations))
!------------------------------------------------------------------------
    case(8)
       ifastrender = .not.ifastrender
       print "(a)",' Accelerated rendering is '//trim(print_logical(ifastrender))
       if (ifastrender) then
          print*,' Warning: this is slightly approximate (particle position'
          print*,'          assumed to be at centre of pixel)'
       endif
!------------------------------------------------------------------------
    case(9)
       idensityweightedinterpolation = .not.idensityweightedinterpolation
       print "(a)",' Density weighted interpolation is '// &
                   print_logical(idensityweightedinterpolation)
!------------------------------------------------------------------------
    case(10)
       print "(5(/,a),/,4(/,a),/)", &
                        ' Example format strings: ', &
                        '  \(2268) %l d%z %uz       : this is the default format "\int rho [g/cm^3] dz [cm]"', &
                        '   column %l               : would print "column density" for density', &
                        '  surface %l               : would print "surface density"', &
                        '  %l integrated through %z : would print "density integrated through z"', &
                        ' Format codes: ', &
                        ' %l  : label for rendered quantity ', &
                        ' %z  : label for ''z'' ', &
                        ' %uz : units label for z (only if physical units applied)'
                        
       call prompt(' enter label format for projection plots: ',projlabelformat)
       call prompt(' enter which column to apply format to (0=all) ',iapplyprojformat,0,maxplot)
  end select
    
 return
end subroutine submenu_render

end module settings_render