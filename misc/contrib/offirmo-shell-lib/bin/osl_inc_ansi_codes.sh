#! /bin/bash

## Offirmo Shell Library
## https://github.com/Offirmo/offirmo-shell-lib
##
## This file defines :
##   - ANSI terminal control sequences
##     for color, style, etc.
##
## This file is meant to be sourced :
##    source osl_inc_ansi_codes.sh


if [[ "$TERM" != "xterm" ]]; then
	# It seems that this terminal has no ANSI codes capabilities.
	# We don't define any color :
	# vars will be substituted by nothing.
	do_nothing=1
else
	# terminal has ANSI codes capabilities.
	
	### ANSI color and format codes
	OSL_ANSI_CODE_ESCAPE_CHAR="\033"
	#ANSI_ESCAPE_CHAR="\e"
	
	OSL_ANSI_CODE_SEQUENCE_BEGIN="${OSL_ANSI_CODE_ESCAPE_CHAR}["
	OSL_ANSI_CODE_SEQUENCE_SEPARATOR=";"
	OSL_ANSI_CODE_SEQUENCE_END="m"
	
	OSL_ANSI_CODE_SUBSEQUENCE_RESET="0"
	OSL_ANSI_CODE_SUBSEQUENCE_SET_BRIGHT="1" # usually rendered as bold
	OSL_ANSI_CODE_SUBSEQUENCE_SET_DIM="2" # usually rendered as normal
	OSL_ANSI_CODE_SUBSEQUENCE_SET_ITALICS="3" # usually NOT rendered
	OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND="3" # + color code
	OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND="4" # + color code
	OSL_ANSI_CODE_SUBSEQUENCE_SET_UNDERLINE="4" # conflicting ?
	OSL_ANSI_CODE_SUBSEQUENCE_SET_BLINK="5"
	OSL_ANSI_CODE_SUBSEQUENCE_SET_REVERSE="7"
	OSL_ANSI_CODE_SUBSEQUENCE_SET_HIDDEN="8" # doesn't do anything...
	
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_BLACK="0"
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_RED="1"
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_GREEN="2"
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_YELLOW="3"
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_BLUE="4"
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_MAGENTA="5"
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_CYAN="6"
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_WHITE="7" # this is more a "light gray" in fact.
	# no established color for 8
	OSL_ANSI_CODE_SUBSEQUENCE_COLOR_DEFAULT="9"
	
	OSL_ANSI_CODE_SET_FG_BLACK="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_BLACK}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_FG_RED="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_RED}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_FG_GREEN="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_GREEN}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_FG_YELLOW="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_YELLOW}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_FG_BLUE="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_BLUE}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_FG_MAGENTA="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_MAGENTA}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_FG_CYAN="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_CYAN}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_FG_WHITE="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_WHITE}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_FG_DEFAULT="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_FOREGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_DEFAULT}${OSL_ANSI_CODE_SEQUENCE_END}"
	
	OSL_ANSI_CODE_SET_BG_BLACK="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_BLACK}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BG_RED="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_RED}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BG_GREEN="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_GREEN}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BG_YELLOW="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_YELLOW}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BG_BLUE="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_BLUE}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BG_MAGENTA="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_MAGENTA}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BG_CYAN="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_CYAN}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BG_WHITE="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_WHITE}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BG_DEFAULT="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BACKGROUND}${OSL_ANSI_CODE_SUBSEQUENCE_COLOR_DEFAULT}${OSL_ANSI_CODE_SEQUENCE_END}"
	
	OSL_ANSI_CODE_RESET="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_RESET}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_BRIGHT="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_BRIGHT}${OSL_ANSI_CODE_SEQUENCE_END}"
	OSL_ANSI_CODE_SET_DIM="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_SET_DIM}${OSL_ANSI_CODE_SEQUENCE_END}"
	#ANSI_SET_ITALICS                = SEQUENCE_BEGIN + SUBSEQUENCE_SET_ITALICS    + SEQUENCE_END
	OSL_ANSI_CODE_SET_UNDERLINE="${OSL_ANSI_CODE_SEQUENCE_BEGIN}${OSL_ANSI_CODE_SUBSEQUENCE_UNDERLINE}${OSL_ANSI_CODE_SEQUENCE_END}"
	#ANSI_SET_BLINK                  = SEQUENCE_BEGIN + SUBSEQUENCE_SET_BLINK      + SEQUENCE_END
	#ANSI_SET_REVERSE                = SEQUENCE_BEGIN + SUBSEQUENCE_SET_REVERSE    + SEQUENCE_END
	#ANSI_SET_HIDDEN                 = SEQUENCE_BEGIN + SUBSEQUENCE_SET_HIDDEN     + SEQUENCE_END
	
	
fi # ANSI code capabilities