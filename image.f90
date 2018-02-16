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

subroutine colourise(niter, nx, ny, cpt, imgfile)
    implicit none
    real(kind=real64), intent(in), dimension(nx,ny) :: niter
    integer(kind=int32), intent(in)                 :: nx, ny
    character(len=*), intent(in)                    :: cpt
    character(len=*), intent(in)                    :: imgfile

    real(kind=real64), allocatable                  :: niter_flat(:)
    integer(kind=int32), allocatable                :: niter_rank(:)
    real(kind=real64), allocatable                  :: normalised(:, :)
    integer(kind=int32)                             :: i, j
    integer(kind=int32),dimension(3)                :: rgb
    integer                                         :: nout

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
                select case (cpt)
                    case ("grey")
                        call cpt_grey(normalised(i, j), rgb)
                    case ("haxby")
                        call cpt_haxby(normalised(i, j), rgb)
                    case ("rainbow")
                        call cpt_rainbow(normalised(i, j), rgb)
                    case ("seis")
                        call cpt_seis(normalised(i, j), rgb)
                    case ("plasma")
                        call cpt_plasma(normalised(i, j), rgb)
                    case ("hot")
                        call cpt_hot(normalised(i, j), rgb)
                    case ("jet")
                        call cpt_jet(normalised(i, j), rgb)
                    case ("viridis")
                        call cpt_viridis(normalised(i, j), rgb)
                    case default
                        call cpt_haxby(normalised(i, j), rgb)
                end select
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
    real(kind=real64), intent(in)                   :: val
    real(kind=real64), intent(in), dimension(:)     :: lev
    integer(kind=int32), intent(in), dimension(:)   :: cptr, cptg, cptb
    integer(kind=int32), intent(out), dimension(3)  :: rgb

    real(kind=real64)                               :: interp
    integer(kind=int32)                             :: i

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
    real(kind=real64), intent(in)                   :: val
    integer(kind=int32), intent(out), dimension(3)  :: rgb
    real(kind=real64), dimension(2)                 :: lev
    integer(kind=int32), dimension(2)               :: r, g, b

    lev = (/0, 1/) 
    r   = (/0, 255/)
    g   = (/0, 255/)
    b   = (/0, 255/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

subroutine cpt_haxby(val, rgb)
    implicit none
    real(kind=real64), intent(in)                   :: val
    integer(kind=int32), intent(out), dimension(3)  :: rgb
    real(kind=real64), dimension(32)                :: lev
    integer(kind=int32), dimension(32)              :: r, g, b
    integer(kind=int32)                             :: i

    do i=1,32
        lev(i) = real((i-1),real64)/31.0
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

subroutine cpt_rainbow(val, rgb)
    implicit none
    real(kind=real64), intent(in)                   :: val
    integer(kind=int32), intent(out), dimension(3)  :: rgb
    real(kind=real64), dimension(50)                :: lev
    integer(kind=int32), dimension(50)              :: r, g, b
    integer(kind=int32)                             :: i

    do i=1,50
        lev(i) = real((i-1),real64)/49.0
    end do

    r = (/242,216,191,165,140,114,89,63,38,12,&
    &0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,0,0,&
    &12,38,63,89,114,140,165,191,216,242,&
    &255,255,255,255,255,255,255,255,255,255/)
    g = (/0,0,0,0,0,0,0,0,0,0,&
    &12,38,63,89,114,140,165,191,216,242,&
    &255,255,255,255,255,255,255,255,255,255,&
    &255,255,255,255,255,255,255,255,255,255,&
    &242,216,191,165,140,114,89,63,38,12/)
    b = (/255,255,255,255,255,255,255,255,255,255,&
    &255,255,255,255,255,255,255,255,255,255,&
    &242,216,191,165,140,114,89,63,38,12,&
    &0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,0,0/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

subroutine cpt_seis(val, rgb)
    implicit none
    real(kind=real64), intent(in)                   :: val
    integer(kind=int32), intent(out), dimension(3)  :: rgb
    real(kind=real64), dimension(50)                :: lev
    integer(kind=int32), dimension(50)              :: r, g, b
    integer(kind=int32)                             :: i

    do i=1,50
        lev(i) = real((i-1),real64)/49.0
    end do

    r = (/177,192,208,223,238,254,255,255,255,255,&
    &255,255,255,255,255,255,255,255,255,255,&
    &255,255,255,255,255,255,255,255,233,203,&
    &174,144,114,87,71,54,38,22,6,0,&
    &0,0,0,0,0,0,0,0,0,0/)
    g = (/0,0,0,0,0,0,14,29,45,60,&
    &75,90,106,121,136,152,167,182,198,213,&
    &228,243,255,255,255,255,255,255,255,255,&
    &255,255,255,254,251,249,246,243,241,222,&
    &193,164,136,107,79,64,50,36,21,7/)
    b = (/0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,3,9,&
    &14,20,25,32,46,61,75,90,104,125,&
    &152,178,204,230,254,245,236,227,218,209/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

subroutine cpt_plasma(val, rgb)
    implicit none
    real(kind=real64), intent(in)                   :: val
    integer(kind=int32), intent(out), dimension(3)  :: rgb
    real(kind=real64), dimension(50)                :: lev
    integer(kind=int32), dimension(50)              :: r, g, b
    integer(kind=int32)                             :: i

    do i=1,50
        lev(i) = real((i-1),real64)/49.0
    end do

    r = (/20,33,43,52,61,70,78,86,94,102,&
    &110,118,125,133,140,148,154,161,167,173,&
    &179,185,190,195,200,205,210,214,218,222,&
    &226,230,233,237,240,243,246,248,250,251,&
    &252,253,254,253,253,251,249,247,244,241/)
    g = (/7,6,5,4,4,3,2,1,1,0,&
    &0,1,3,5,10,16,22,27,33,39,&
    &45,50,56,61,67,74,79,85,91,97,&
    &103,109,115,121,127,135,141,148,155,162,&
    &170,177,185,193,201,210,218,226,235,244/)
    b = (/137,143,147,151,155,159,162,164,166,167,&
    &168,168,168,166,165,161,158,154,150,146,&
    &141,136,132,127,122,117,113,108,104,99,&
    &95,91,87,82,78,73,68,64,60,56,&
    &51,47,44,41,38,36,36,37,39,37/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

subroutine cpt_hot(val, rgb)
    implicit none
    real(kind=real64), intent(in)                   :: val
    integer(kind=int32), intent(out), dimension(3)  :: rgb
    real(kind=real64), dimension(50)                :: lev
    integer(kind=int32), dimension(50)              :: r, g, b
    integer(kind=int32)                             :: i

    do i=1,50
        lev(i) = real((i-1),real64)/49.0
    end do

    r = (/6,20,34,47,61,74,88,102,115,129,&
    &142,156,170,183,197,210,224,238,251,255,&
    &255,255,255,255,255,255,255,255,255,255,&
    &255,255,255,255,255,255,255,255,255,255,&
    &255,255,255,255,255,255,255,255,255,255/)
    g = (/0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,0,10,&
    &23,37,51,64,78,91,105,119,132,146,&
    &159,173,187,200,214,227,241,255,255,255,&
    &255,255,255,255,255,255,255,255,255,255/)
    b = (/0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,20,40,&
    &61,81,102,122,142,163,183,204,224,244/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

subroutine cpt_jet(val, rgb)
    implicit none
    real(kind=real64), intent(in)                   :: val
    integer(kind=int32), intent(out), dimension(3)  :: rgb
    real(kind=real64), dimension(50)                :: lev
    integer(kind=int32), dimension(50)              :: r, g, b
    integer(kind=int32)                             :: i

    do i=1,50
        lev(i) = real((i-1),real64)/49.0
    end do

    r = (/0,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,0,15,&
    &35,56,76,96,117,137,158,178,198,219,&
    &239,255,255,255,255,255,255,255,255,255,&
    &255,255,255,255,239,219,198,178,157,137/)
    g = (/0,0,0,0,0,0,5,25,45,66,&
    &86,107,127,147,168,188,209,229,249,255,&
    &255,255,255,255,255,255,255,255,255,255,&
    &255,249,229,209,188,168,147,127,107,86,&
    &66,45,25,5,0,0,0,0,0,0/)
    b = (/137,157,178,198,219,239,255,255,255,255,&
    &255,255,255,255,255,255,255,255,255,239,&
    &219,198,178,158,137,117,96,76,56,35,&
    &15,0,0,0,0,0,0,0,0,0,&
    &0,0,0,0,0,0,0,0,0,0/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

subroutine cpt_viridis(val, rgb)
    implicit none
    real(kind=real64), intent(in)                   :: val
    integer(kind=int32), intent(out), dimension(3)  :: rgb
    real(kind=real64), dimension(50)                :: lev
    integer(kind=int32), dimension(50)              :: r, g, b
    integer(kind=int32)                             :: i

    do i=1,50
        lev(i) = real((i-1),real64)/49.0
    end do

    r = (/69,70,71,72,72,72,71,69,68,66,&
    &63,61,59,56,54,51,49,46,44,42,&
    &41,39,37,35,33,32,31,30,31,33,&
    &36,40,46,54,62,72,82,92,103,115,&
    &128,140,154,167,180,194,208,221,234,246/)
    g = (/4,12,19,26,32,40,46,52,58,64,&
    &70,76,81,87,92,98,103,108,113,117,&
    &122,127,131,136,141,146,151,156,161,165,&
    &170,174,179,183,188,193,197,200,204,208,&
    &211,214,216,219,221,223,225,227,229,230/)
    b = (/88,95,102,108,114,120,124,128,131,134,&
    &136,138,139,140,141,141,142,142,142,142,&
    &142,142,142,142,141,140,139,137,135,133,&
    &130,127,124,120,115,109,104,98,91,85,&
    &77,69,60,52,43,34,27,24,26,32/)

    call interpcolour(val, lev, r, g, b, rgb)
end subroutine

end module
