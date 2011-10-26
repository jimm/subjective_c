#ifndef _Stream_h_
#define _Stream_h_

#include <subjc/Object.h>

#define STREAM_READ	  0x0001
#define STREAM_WRITE	 0x0002
#define STREAM_READWRITE 0x0003
#define STREAM_APPEND	0x0004
#define STREAM_CREATE	0x0008
#define STREAM_BINARY	0x0010

typedef long StreamCount, StreamPos;

enum {							/* Arguments to seek:from: */
	StreamFromTop,
	StreamFromBottom,
	StreamFromCurr
};

@interface Stream : Object
{
	StreamPos pos;				/* Current position */
	StreamCount length;			/* Length of data (number of bytes) */
	StreamCount allocated;		/* Allocated size */
	char *fileName;				/* Only used if it's opened on a file */
	unsigned char *data;		/* Memory */
	BOOL isWritable;			/* YES if user asked for STREAM_WRITE */
	BOOL isBinary;				/* YES if user asked for STREAM_BINARY */
}

- initFromFile: (char *)fname mode: (int)mode;

- free;

- flush;

- seek: (StreamPos)pos from: (int)where; /* Sets current position */
- (StreamPos)tell;				/* Returns current position */

- (int)getc;					/* Gets next char */
- putc: (int)ch;				/* Puts char at current position and moves */
- ungetc;						/* Ungets char */

- (BOOL)atEos;					/* Returns TRUE if at end of stream */

- gets: (char *)buf maxlen: (int)maxlen;
- puts: (char *)buf;

- (StreamCount)read: (char *)buf len: (StreamCount)len;
- (StreamCount)write: (char *)buf len: (StreamCount)len;

@end

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* _Stream_h_ */
