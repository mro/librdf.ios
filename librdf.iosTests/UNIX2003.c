//
// UNIX2003.c
// librdf.objc
//
// Created by Marcus Rohrmoser on 20.06.14.
// Copyright (c) 2014-2015 Marcus Rohrmoser mobile Software. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification, are permitted
// provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this list of conditions
// and the following disclaimer.
//
// 2. The software must not be used for military or intelligence or related purposes nor
// anything that's in conflict with human rights as declared in http://www.un.org/en/documents/udhr/ .
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
// FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
// IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#include <dirent.h>
#include <stdio.h>
#include <time.h>
#include <regex.h>
#include <string.h>
#include <stdlib.h>

/** https://stackoverflow.com/questions/9575023/xcode-code-coverage-and-fopenunix2003
 */
/* DIR *opendir$INODE64$UNIX2003(const char *dirname)
{
    return opendir(dirname);
}
*/

FILE *fopen$UNIX2003(const char *__restrict filename, const char *__restrict mode)
{
    return fopen(filename, mode);
}


size_t fwrite$UNIX2003(const void *__restrict ptr, size_t size, size_t nitems, FILE *__restrict stream)
{
    return fwrite(ptr, size, nitems, stream);
}


int fputs$UNIX2003(const char *__restrict s, FILE *__restrict stream)
{
    return fputs(s, stream);
}


clock_t clock$UNIX2003()
{
    return clock();
}


time_t mktime$UNIX2003(struct tm *timeptr)
{
    return mktime(timeptr);
}


int regcomp$UNIX2003(regex_t *restrict preg, const char *restrict pattern, int cflags)
{
    return regcomp(preg, pattern, cflags);
}


char *strerror$UNIX2003(int i)
{
    return strerror(i);
}


size_t strftime$UNIX2003(char *restrict s, size_t maxsize, const char *restrict format, const struct tm *restrict timeptr)
{
    return strftime(s, maxsize, format, timeptr);
}


double strtod$UNIX2003(const char *restrict nptr, char **restrict endptr)
{
    return strtod(nptr, endptr);
}


// void rewinddir$INODE64$UNIX2003(DIR *dir) { rewinddir(dir); }
