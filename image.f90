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

module image
use, intrinsic  :: iso_fortran_env
use m_mrgrnk

contains

subroutine colourise(niter, nx, ny, imgfile)
    implicit none
    real(real64), intent(in), dimension(nx,ny)  :: niter
    integer(int32), intent(in)                  :: nx, ny
    character(len=*), intent(in)                :: imgfile

    real(real64), allocatable                   :: niter_flat(:)
    integer(int32), allocatable                 :: niter_rank(:)
    real(real64), allocatable                   :: normalised(:, :)
    integer(int32)                              :: i, j
    integer(int32),dimension(3)                 :: rgb
    integer                                     :: nout

    allocate(normalised(nx, ny))
    allocate(niter_flat(nx*ny))
    allocate(niter_rank(nx*ny))

    niter_flat = reshape(niter, (/nx*ny/))
    call mrgrnk(niter_flat, niter_rank)

    do i=1,ny*nx
        niter_flat(niter_rank(i)) = real(i, real64)/(ny*nx)
    end do
    normalised = reshape(niter_flat, (/nx, ny/))

    !
    ! Apply a colour palette to the normalised data,
    ! and save it as a PPM image
    !
    open(newunit=nout, status="replace", form='formatted', file=imgfile)
    write(unit=nout, fmt="(A2,3I8)") "P6", nx, ny, 255
    close(unit=nout)

    open(newunit=nout, form='unformatted', access='stream', position='append', file=imgfile)
    do j=ny,1,-1
        do i=1,nx
            if (niter(i,j) > 0) then
                call cpt_haxby(normalised(i, j), rgb)
            else
                rgb = (/0, 0, 0/)
            end if
            write(unit=nout) int(huge(int8)-255+rgb, int8)
        end do
    end do
    close(unit=nout)

    !
    ! Deallocate memory.
    !
    deallocate(normalised)
    deallocate(niter_flat)
    deallocate(niter_rank)

end subroutine

subroutine interpcolour(val, lev, cptr, cptg, cptb, rgb)
    implicit none
    real(real64), intent(in)                    :: val
    real(real64), intent(in), dimension(:)      :: lev
    integer(int32), intent(in), dimension(:)    :: cptr, cptg, cptb
    integer(int32), intent(out), dimension(3)   :: rgb

    real(real64)                                :: interp
    integer(int32)                              :: i

    do i=2,size(lev)
        if ((val >= lev(i-1)) .and. (val < lev(i))) then
            interp = (val - lev(i-1))/(lev(i) - lev(i-1))
            rgb(1) = int(interp*(cptr(i)-cptr(i-1)), int32) + cptr(i-1)
            rgb(2) = int(interp*(cptg(i)-cptg(i-1)), int32) + cptg(i-1)
            rgb(3) = int(interp*(cptb(i)-cptb(i-1)), int32) + cptb(i-1)
        endif
    end do
end subroutine

subroutine cpt_grey(val, rgb)
    implicit none
    real(real64), intent(in)                    :: val
    integer(int32), intent(out), dimension(3)   :: rgb
    real(real64), dimension(2)                  :: lev
    integer(int32), dimension(2)                :: r, g, b

    lev = (/0, 1/) 
    r   = (/0, 255/)
    g   = (/0, 255/)
    b   = (/0, 255/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

subroutine cpt_haxby(val, rgb)
    implicit none
    real(real64), intent(in)                    :: val
    integer(int32), intent(out), dimension(3)   :: rgb
    real(real64), dimension(32)                 :: lev
    integer(int32), dimension(32)               :: r, g, b
    integer(int32)                              :: i

    do i=1,32
        lev(i) = real((i-1),real32)/31.0
    end do

    r = (/ 10, 40, 20,  0,  0,  0, 26, 13, 25, 50, 68, 97,&
        &106,124,138,172,205,223,240,247,255,255,244,238,255,&
        &255,255,245,255,255,255,255/)
    g = (/  0,  0,  0, 10, 25, 40,102,129,175,190,202,225,&
        &235,235,236,245,255,245,236,215,189,160,117, 80, 90,&
        &124,158,179,196,215,235,254/) 
    b = (/121,150,175,200,212,224,240,248,255,255,255,240,&
        &225,200,174,168,162,141,121,104, 87, 69, 75, 78, 90,&
        &124,158,174,196,215,235,253/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

end module
