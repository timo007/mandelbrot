! This module contains code to implement Sergey Khashin's
! algorithm. See: http://math.ivanovo.ac.ru/dalgebra/Khashin/man2/Mandelbrot.pdf

module mbperturb
use, intrinsic  :: iso_fortran_env
use mbmath

contains

subroutine mbplane(cr, ci, nx, ny, zoom, itermax, ncritr)
    real(kind=real128), intent(in)                      :: cr, ci   ! Will need to be MP later on.
    integer(kind=int32), intent(in)                     :: nx
    integer(kind=int32), intent(in)                     :: ny
    real(kind=real128), intent(in)                      :: zoom
    integer(kind=int64), intent(in)                     :: itermax
    real(kind=real64), dimension(nx, ny), intent(out)   :: ncritr

    complex(kind=real128)                               :: cpnt
    real(kind=real128)                                  :: inc
    complex(kind=real128)                               :: delta    ! Will need to be MP later on.
    complex(kind=real64)                                :: h        ! real64 should suffice.
    complex(kind=real128), dimension(0:itermax-1)       :: fc       ! Mandelbrot function at the centre.
    complex(kind=real64)                                :: fdelta   ! Mandelbrot function at offset points.
    real(kind=real64)                                   :: mag2     ! Magnitude squared of fdelta

    integer(kind=int64)                         :: n        ! Iteration counter.
    integer(kind=int32)                         :: i, j
    real(kind=real128)                          :: dr, di


    !
    ! Compute the centre point at high precision.
    !
    print *,'Computing high precision point'
    cpnt = cmplx(cr, ci, kind=real128)
    fc(0) = 0
    do n=1,itermax-1
        fc(n) = fc(n-1)**2 + cpnt
    end do

    !
    ! Recursively calculate the Mandelbrot function.
    !
    inc = 1.0/real(ny, kind=real128)/zoom
    do j=1,ny
        di = real(((j-ny/2)*inc), kind=real128)
        do i=1,nx
            dr = real(((i-nx/2)*inc), kind=real128)
            delta = cmplx(dr, di, kind=real128)
            mag2 = 0
            h = 0
            n = 0
            do while ((n < itermax) .and. (mag2 < 65536))
                fdelta = cmplx(fc(n), kind=real64) + cmplx(delta, kind=real64)*h
                mag2 = real(fdelta, kind=real64)**2 + aimag(fdelta)**2
                !
                ! Compute h for the next iteration.
                !
                h = h*(2*cmplx(fc(n), kind=real64) + cmplx(delta, kind=real64)*h) + 1
                n = n + 1
            end do

            if (n < itermax) then
                ncritr(i,j) = real(n, kind=real64) + 1.0 - log((log(mag2)/2.0)/log(2.0))/log(2.0)
            else
                ncritr(i,j) = 0.0
            end if
        end do
    end do

end subroutine

end module
