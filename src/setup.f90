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

module setup
use, intrinsic  :: iso_fortran_env
use mbtypes

contains

subroutine read_cmd(cr, ci, nx, ny, zoom, itermax, cpt, imgfile)
    real(realmb), intent(out)          :: cr
    real(realmb), intent(out)          :: ci
    integer(int32), intent(out)         :: nx
    integer(int32), intent(out)         :: ny
    real(realmb), intent(out)          :: zoom
    integer(int32), intent(out)         :: itermax
    character(len=128), intent(out)    :: cpt
    character(len=1024), intent(out)    :: imgfile

    character(len=1024)                 :: arg1, arg2, arg3
    integer(int32)                      :: i
    integer(int32)                      :: ioss

    !
    ! Default values.
    !
    cr      = 0.0
    ci      = 0.0
    nx      = 1920
    ny      = 1080
    zoom    = 1.0
    itermax = 500
    cpt     = "haxby"
    imgfile = "mb.ppm"


    do i=1, command_argument_count()
        call get_command_argument(i, arg1)
        select case (trim(arg1))
            case ("-o")
                call get_command_argument(i+1, imgfile)
            case ("-p")
                call get_command_argument(i+1, cpt)
            case ("-x")
                call get_command_argument(i+1, arg2)
                read(arg2, *, iostat=ioss) nx
                if (ioss /= 0) then
                    print *,"Error while reading image width"
                    stop
                end if
            case ("-y")
                call get_command_argument(i+1, arg2)
                read(arg2, *, iostat=ioss) ny
                if (ioss /= 0) then
                    print *,"Error while reading image height"
                    stop
                end if
            case ("-c")
                call get_command_argument(i+1, arg2)
                call get_command_argument(i+2, arg3)
                read(arg2, *, iostat=ioss) cr
                if (ioss /= 0) then
                    print *,"Error while reading image centre, real part"
                    stop
                end if
                read(arg3, *, iostat=ioss) ci
                if (ioss /= 0) then
                    print *,"Error while reading image centre, imag part"
                    stop
                end if
            case ("-i")
                call get_command_argument(i+1, arg2)
                read(arg2, *, iostat=ioss) itermax
                if (ioss /= 0) then
                    print *,"Error while reading maximum iteration value"
                    stop
                end if
            case ("-z")
                call get_command_argument(i+1, arg2)
                read(arg2, *, iostat=ioss) zoom
                if (ioss /= 0) then
                    print *,"Error while reading zoom factor"
                    stop
                end if
        end select
    end do
end subroutine

end module
