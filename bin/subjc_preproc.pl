#! /usr/bin/env perl -n

s#\s*//.*##;
if (/#\s*import\s+[\"<]([^\">]*)[\">]/) {
    ($symbol = $1) =~ tr/./_/;
    print "#ifndef $symbol\n";
    print "#define $symbol\n";
    s/#\s*import/#include/;
    print $_;
    print "#endif /* $symbol */\n";
}
else {
    print;
}
