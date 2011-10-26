#ifndef error_h_
#define error_h_

extern void Error(const char *errmsg);
extern void FatalError(const char *errmsg);

extern void SetPreprocFileName(const char *fileName);
extern const char * GetPreprocFileName();

extern void SetIncludeFileName(const char *fileName);
extern const char * GetIncludeFileName();

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* error_h_ */
