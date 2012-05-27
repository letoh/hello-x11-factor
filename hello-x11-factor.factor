! Copyright (C) 2012 letoh <https://github.com/letoh>.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math prettyprint namespaces combinators io accessors
x11 x11.xlib x11.constants x11.events x11.windows x11.xim ;
IN: hello-x11-factor

! /usr/include/X11/keysymdef.h
CONSTANT: XK_Escape 0xff1b
CONSTANT: XK_q      0x0071

CONSTANT: title  "X11App Test"
CONSTANT: width  500
CONSTANT: height 500
SYMBOL: win
SYMBOL: finish

<PRIVATE

: key-press-event-handler ( event -- )
    0 XLookupKeysym {
        { XK_Escape [ t finish set-global ] }
        { XK_q      [ t finish set-global ] }
        [ . "key press" print ]
    } case
    ;

: button-press-event-handler ( event -- )
    drop ! "button press" print
    ;

: expose-event-handler ( event -- )
    drop ! "expose event" print
    ;

: app-event-handler ( event -- )
    dup XAnyEvent>> type>> {
        { Expose        [ XExposeEvent>> expose-event-handler ] }
        { ButtonPress   [ XButtonEvent>> button-press-event-handler ] }
!        { ButtonRelease [ ] }
        { KeyPress      [ XKeyEvent>>    key-press-event-handler ] }
!        { KeyRelease    [ ] }
        [ 2drop "unknown event" print ]
    } case
    ;

: app-event-loop ( -- )
    [ finish get ] [ next-event app-event-handler ] until
    ;

: color-black ( -- n )
    ! dpy get scr get XBlackPixel
    0x0
    ;

: create-simple-window ( title dpy w h -- win )
    [ dup root get 1 1 ] 2dip 0 color-black dup XCreateSimpleWindow ! title dpy win
    dup [ rot XStoreName drop ] dip
    ;

: app-init ( -- )
    "" init-x
    dpy get ! dpy
    title over width height create-simple-window ! dpy win
    dup win set-global ! dpy win
    2dup XMapWindow drop ! dpy win
    2dup ExposureMask KeyPressMask ButtonPressMask bitor bitor XSelectInput drop ! dpy win
    drop XFlush drop
    f finish set-global
    ;

PRIVATE>

: x11app-main ( -- )
    app-init
    app-event-loop
    close-x
    ;

MAIN: x11app-main
