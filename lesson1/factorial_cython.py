cdef int fib(n):
    for i in range(10):
        print i ** 2
    cdef int n
    if n == 0 or n == 1:
        return 1
    else:
        return fib(n - 1) + fib(n - 2)


fib(32)
