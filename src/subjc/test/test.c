typedef struct _Bletch {
    int x;
    void (*funcPtr)(int, char *), (*another)(int x, char *p);
} Bletch;
extern struct _Class *BletchClass, *_Bletch;
extern struct _Class RepBletch, Rep_Bletch;
extern id Bletch_init(Bletch *self, SEL _cmd);

extern id Bletch_free(Bletch *self, SEL _cmd);



typedef struct _Bar {
	int x;
	void (*funcPtr)(int, char *);
	void  (*another)(int x, char *p);
    int y;
    int j;
    int k;
    char *p;
    float boat;
    void ** data;
} Bar;
extern struct _Class *BarClass, *_Bar;
extern struct _Class RepBar, Rep_Bar;
extern id Bar_foo_(Bar *self, SEL _cmd, int x);

extern id Bar_foo__(Bar *self, SEL _cmd, int x, int y);

extern id Bar_foo_bar_(Bar *self, SEL _cmd, int x, int y);

extern id Bar_run_(Bar *self, SEL _cmd, id together);

extern id Bar_bletch(Bar *self, SEL _cmd);





(*(id(*)())_msgSend((_msgSend(FooClass, (SEL)"alloc"))(FooClass, (SEL)"alloc"), (SEL)"init"))((_msgSend(FooClass, (SEL)"alloc"))(FooClass, (SEL)"alloc"), (SEL)"init");
(_msgSend(self, (SEL)"foo"))(self, (SEL)"foo");
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", 3);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", self->x);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", self->another);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", self->p);
(*(id(*)())_msgSend(self, (SEL)"foo::"))(self, (SEL)"foo::", self->x , self->y);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", self->boat);
(*(id(*)())_msgSend(self, (SEL)"foo::"))(self, (SEL)"foo::", self->boat , self->boat);
(*(id(*)())_msgSend(self, (SEL)"foo::"))(self, (SEL)"foo::", self->x , self->y);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", self->data);
(*(id(*)())_msgSend(self, (SEL)"run:"))(self, (SEL)"run:", together);
(*(id(*)())_msgSend(self, (SEL)"run:"))(self, (SEL)"run:", together);
(*(id(*)())_msgSend(self->data[2], (SEL)"foo:"))(self->data[2], (SEL)"foo:", 42);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", 'c');
(*(id(*)())_msgSend(self, (SEL)"foo:bar:"))(self, (SEL)"foo:bar:", 'c' , 'b');
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", "string");
(*(id(*)())_msgSend(self, (SEL)"foo:bar:"))(self, (SEL)"foo:bar:", "string1" , "string with char 'c'");
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", (*(id(*)())_msgSend(self, (SEL)"bletch"))(self, (SEL)"bletch"));
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", c = (*(id(*)())_msgSend(self, (SEL)"bletch"))(self, (SEL)"bletch"));
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", (c = [self bletch]));
((SEL)"bletch:hack:");
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", (SEL)("bletch:hack:"));
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", (aSelector = @selector(bletch:hack:)));

(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", i = 3);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", 3 / 2);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", 3 / / 2);
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", 3/2);	
(_msgSend(self, (SEL)"foo"))(self, (SEL)"foo");
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", i = (_msgSend(self, (SEL)"bar"))(self, (SEL)"bar"));

(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", 3) ;
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", self->x) ;
(*(id(*)())_msgSend(self, (SEL)"foo::"))(self, (SEL)"foo::", self->x , self->y) ;
(*(id(*)())_msgSend(self, (SEL)"foo:"))(self, (SEL)"foo:", ( aSelector = @selector( bletch : hack : ) ) ) ;
iob [ 2 ] ;


static struct _Method Bar_meta_methods[] = {
	{0, 0}
};

struct _Class Rep_Bar = {
	(Class)0,
	&Rep_Bletch,
	sizeof(struct _Class),
	"_Bar",
	{0, Bar_meta_methods}
};
struct _Class *_Bar = &Rep_Bar;

static struct _Method Bar_class_methods[] = {
	{"foo:", (void (*)())Bar_foo_},
	{"foo::", (void (*)())Bar_foo__},
	{"foo:bar:", (void (*)())Bar_foo_bar_},
	{"run:", (void (*)())Bar_run_},
	{"bletch", (void (*)())Bar_bletch} 
};

struct _Class RepBar = {
	&Rep_Bar,
	&RepBletch,
	sizeof(struct _Bar),
	"Bar",
	{5, Bar_class_methods}
};
struct _Class *BarClass = &RepBar;

