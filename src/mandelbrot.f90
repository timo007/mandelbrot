! Copyright 2018 Timothy Hume
!
! Permission to use, copy, modify, and/or distribute this software for any
! purpose with or without fee is hereby granted, provided that the above
! copyright notice and this permission notice appear in all copies.
!
! THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
! REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
! INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
! LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
! OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
! PERFORMANCE OF THIS SOFTWARE.

program mandelbrot
    use, intrinsic  :: iso_fortran_env
    use mbtypes
    use setup
    use image
    use mbmath
    use mbperturb
    implicit none

    !
    ! Variables read from the command line.
    !
    character(len=1024)         :: imgfile  ! Name of image file to create
    character(len=128)          :: cpt      ! Name of colour palette to use
    integer(int32)              :: nx       ! Width of image
    integer(int32)              :: ny       ! Height of image
    integer(int64)              :: itermax  ! Maximimum number of iterations
    real(real128)               :: zoom     ! Zoom factor
    real(real128)               :: cr       ! Real part of centre point
    real(real128)               :: ci       ! Imaginary part of centre point

    real(real64), allocatable   :: niter(:,:) ! Results array

    !
    ! Read the command line.
    !
    call read_cmd(cr, ci, nx, ny, zoom, itermax, cpt, imgfile)

    !
    ! Allocate memory for the niter array.
    !
    allocate(niter(nx, ny))

    !
    ! Compute the Mandelbrot set for the points of interest.
    !
    call fillplane(real(cr, realmb), real(ci, realmb), nx, ny, real(zoom, realmb), itermax, niter)
    !call mbplane(cr, ci, nx, ny, zoom, itermax, niter)

    !
    ! Colorise the set.
    !
    call colourise(niter, nx, ny, cpt, imgfile)

    deallocate(niter)

end program
