#ifndef xlate_h_
#define xlate_h_

extern void DoInterface(void);
extern void DoImplementation(void);
extern void DoFuncHeader(int type);
extern void DoEnd(void);
extern void DoClass(void);
extern void DoSelector(void);
extern char *CurrClassName(void);
extern char *CurrSuperclassName(void);
extern void CollectDelims(int open, int close, char *buf, char *errType);
extern void PassDelims(int open, int close, char *errType);

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* xlate_h_ */
