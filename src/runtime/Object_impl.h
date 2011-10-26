#ifndef Object_impl_h_
#define Object_impl_h_

#define Nil ((Class)0)
#ifdef nil
#undef nil
#endif
#define nil ((id)0)

#define NO  ((BOOL)0)
#define YES ((BOOL)1)

typedef char BOOL;
typedef void *id;
typedef char *SEL;
typedef id (*IMP)();

struct super_context
{
	id receiver;
	struct _Class *class;
};

extern struct super_context _gSuperContext;

/* Don't comment these out, just change their value */
/*
 * If SEND_WITHOUT_JUMP is zero, MessageSend.m generated code requires asm
 * munging of the message sending routines so they jump to the found method.
 * This is done in the Makefile with the makejump.pl script.
 */
#define SEND_WITHOUT_JUMP		0 /* Don't jump via asm, return func ptr */

#if SEND_WITHOUT_JUMP
extern IMP _msgSend(id receiver, SEL selector);
extern IMP _msgSuper(struct super_context *context, SEL selector);
#else
extern id _msgSend(id receiver, SEL selector, ...);
extern id _msgSuper(struct super_context *context, SEL selector, ...);
#endif
extern struct _Class *subjc_lookUpClass(const char *className); // DOES NOT WORK YET
extern SEL sel_getUID(const char *selectorName);
extern const char *sel_getName(SEL selector);

/*
;;; Local Variables: ***
;;; tab-width:4 ***
;;; End: ***
*/

#endif /* Object_impl_h_ */
