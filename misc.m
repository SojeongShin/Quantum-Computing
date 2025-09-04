script = 1;
global add inc;
add = @(a, b) a + b
add(1, 2)

inc = @(a) add(a, 1)
inc(2)
misc
who
add(1,2)
inc(2)

