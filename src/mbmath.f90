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

module mbmath
use, intrinsic  :: iso_fortran_env
use mbtypes                             ! For the realmb type.

contains

subroutine fillplane(cr, ci, nx, ny, zoom, itermax, niter)
    implicit none

    real(kind=realmb), intent(in)                       :: cr
    real(kind=realmb), intent(in)                       :: ci
    integer(kind=int32), intent(in)                     :: nx
    integer(kind=int32), intent(in)                     :: ny
    real(kind=realmb), intent(in)                       :: zoom
    integer(kind=int64), intent(in)                     :: itermax
    real(kind=real64), intent(out),  dimension(nx, ny)  :: niter

    real(kind=realmb)                                   :: inc
    real(kind=realmb)                                   :: dx, dy
    integer(kind=int32)                                 :: i, j
    complex(kind=realmb)                                :: c

    inc = 1.0/real(ny,realmb)/zoom

    do j=1,ny
        dy = (j-ny/2)*inc
        do i=1,nx
            dx = (i-nx/2)*inc
                c = cmplx(cr+dx, ci+dy, realmb)
                niter(i, j) = mbpoint(c, itermax)
        end do
    end do

end subroutine

function mbpoint(c, nmax) result(nr)
    implicit none

    complex(kind=realmb), intent(in)     :: c        ! Point being tested
    integer(kind=int64), intent(in)      :: nmax     ! Maximum iterations
    integer(kind=int64)                  :: n        ! Number of iterations
    real(kind=real64)                    :: nr       ! Real version of n
    complex(kind=realmb)                 :: z
    complex(kind=realmb)                 :: zprev    ! Previous value of z
    real(kind=realmb)                    :: mag2     ! abs(z)^2
    real(kind=realmb)                    :: logzn, nu

    n = 1
    z = (0, 0)
    mag2 = 0
    zprev = (0, 0)

    do while ((mag2 < 65536) .and. (n < nmax))
        zprev = z
        z = z**2 + c
        !
        ! If z is the same as at the previous iteration, we can
        ! break out of the loop because we must be in the Mandelbrot
        ! set.
        !

        if (zprev == z) then
            n = nmax
        else
            mag2 = real(z, realmb)**2 + aimag(z)**2
            n = n + 1
        end if
    end do

    if (n < nmax) then
        logzn = log(mag2)/2.0
        nu = log(logzn/log(2.0))/log(2.0)
        nr = real(n, real64) + 1.0 - real(nu, real64)
    else
        nr = 0.0
    end if

end function

end module
