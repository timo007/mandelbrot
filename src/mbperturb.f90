! This module contains code to implement

module mbperturb
use, intrinsic  :: iso_fortran_env
use mbmath

contains

subroutine mbplane(cr, ci, nx, ny, zoom, itermax, ncritr)
    real(kind=real128), intent(in)                      :: cr, ci   ! Will need to be MP later on.
    integer(kind=int32), intent(in)                     :: nx
    integer(kind=int32), intent(in)                     :: ny
    real(kind=real128), intent(in)                      :: zoom
    integer(kind=int64), intent(in)                     :: itermax  ! Might change to int64.
    real(kind=real64), dimension(nx, ny), intent(out)   :: ncritr

    complex(kind=real128)                               :: cpnt
    real(kind=real128)                                  :: inc
    complex(kind=real128), dimension(nx, ny)            :: delta    ! Will need to be MP later on.
    complex(kind=real64), dimension(nx, ny)             :: h        ! real64 should suffice.
    complex(kind=real128)                               :: fc       ! Mandelbrot function at the centre.
    complex(kind=real64), dimension(nx, ny)             :: fdelta   ! Mandelbrot function at offset points.
    real(kind=real64), dimension(nx, ny)                :: mag2     ! Magnitude squared of fdelta
    integer(kind=int64), dimension(nx, ny)              :: ncrit    ! Critical iteration (mgiht change to int64)

    integer(kind=int64)                         :: n        ! Iteration counter.
    integer(kind=int32)                         :: i, j
    real(kind=real128)                          :: dr, di


    !
    ! Compute delta at each point in the plane.
    !
    inc = 1.0/real(ny, real128)/zoom
    do j=1,ny
        di = (j-ny/2)*inc
        do i=1,nx
            dr = (i-nx/2)*inc
            delta(i, j) = cmplx(dr, di, real128)
        end do
    end do

    !
    ! Recursively calculate the Mandelbrot function.
    !
    mag2 = 0
    cpnt = cmplx(cr, ci, real128)
    ncrit = 0
    ncritr = 0
    h   = 0
    fc  = (0, 0)

    do n=1,itermax
        print *,'Hi there ',n
        !
        ! Compute the Mandelbrot function for this iteration at all the offset points.
        !
        where (mag2 < 65536)
            fdelta = real(fc, real64) + real(delta, real64)*h
            mag2 = real(fdelta, real64)**2 + aimag(fdelta)**2
            !
            ! Compute h for the next iteration.
            !
            h = h*(2*real(fc, real64) + real(delta, real64)*h) + 1
        elsewhere
            where (ncrit == 0)
                ncrit = n
                ncritr = real(n, real64) + 1.0 - log((log(mag2)/2.0)/log(2.0))/log(2.0)
            end where
        end where

        !
        ! Compute fc in arbitrary precision for the next iteration.
        !
        fc  = fc**2 + cpnt

    end do

end subroutine

end module
