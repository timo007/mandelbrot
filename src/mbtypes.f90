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

! realmb is an 80 bit real on Intel CPUs when compliled with gfortran.
! Need to make this a selected_kind statement instead.

module mbtypes
use, intrinsic  :: iso_fortran_env
implicit none

#if defined x86_64
    !
    ! On some CPUs (e.g. Intel, AMD84), 80 bit reals are available. Use these
    ! in preference to 64 bit reals because testing indicated there were no
    ! speed implications, and 80 bits allows deeper Mandelbrot zooming.
    !
    integer, parameter  :: realmb = 10
#else
    integer, parameter  :: realmb = real64
#endif

end module
