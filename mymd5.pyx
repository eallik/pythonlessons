from libc.stdlib cimport malloc


cdef union uwb:
    unsigned w
    unsigned char b[4]

ctypedef uwb WBunion


cdef unsigned f0(unsigned abcd[]):
    return ( abcd[1] & abcd[2]) | (~abcd[1] & abcd[3]);

cdef unsigned f1( unsigned abcd[] ):
    return ( abcd[3] & abcd[1]) | (~abcd[3] & abcd[2]);

cdef unsigned f2( unsigned abcd[] ):
    return  abcd[1] ^ abcd[2] ^ abcd[3]

cdef unsigned f3( unsigned abcd[] ):
    return abcd[2] ^ (abcd[1] |~ abcd[3])

ctypedef unsigned (*DgstFctn)(unsigned a[])

cdef unsigned* calcKs( unsigned* k):
    cdef double s, pwr
    cdef int i

    pwr = pow( 2, 32);
    for i in xrange(64):
        s = fabs(sin(1+i))
        k[i] = (unsigned)( s * pwr );
    return k

# ROtate v Left by amt bits
cdef unsigned rol( unsigned v, short amt ):
    cdef unsigned  msk1 = (1 << amt) - 1
    return ((v>>(32-amt)) & msk1) | ((v<<amt) & ~msk1)

cdef union mm_t:
    unsigned w[16]
    char     b[64]


cdef unsigned *md5(char *msg, int mlen):
    cdef unsigned* h0 = [ 0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476 ]
#    cdef unsigned h0[4] = [ 0x01234567, 0x89ABCDEF, 0xFEDCBA98, 0x76543210 ]
    cdef DgstFctn *ff = [ &f0, &f1, &f2, &f3 ]
    cdef short *M = [ 1, 5, 3, 7]
    cdef short *O = [0, 1, 5, 0]
    cdef short *rot0 = [7,12,17,22]
    cdef short *rot1 = [5, 9,14,20]
    cdef short *rot2 = [4,11,16,23]
    cdef short *rot3 = [6,10,15,21]
    cdef short **rots = [rot0, rot1, rot2, rot3]
    cdef unsigned kspace[64]
    cdef unsigned *k

    cdef unsigned h[4]
    cdef unsigned abcd[4]
    cdef DgstFctn fctn
    cdef short m, o, g
    cdef unsigned f
    cdef short *rotn
    cdef mm_t mm
    cdef int os = 0
    cdef int grp, grps, q, p
    cdef unsigned char* msg2
    cdef WBunion u

    if k is None: k = calcKs(kspace)

    for q in xrange(4):
        h[q] = h0[q];   # initialize

    if True:
        grps  = 1 + (mlen+8)/64
        msg2 = malloc( 64*grps)
        memcpy( msg2, msg, mlen)
        msg2[mlen] = <unsigned char> 0x80
        q = mlen + 1
        while q < 64*grps:
            msg2[q] = 0
            q += 1

        if True:
#          cdef unsigned char t
            u.w = 8*mlen
#            t = u.b[0]; u.b[0] = u.b[3]; u.b[3] = t
#            t = u.b[1]; u.b[1] = u.b[2]; u.b[2] = t
            q -= 8
            memcpy(msg2+q, &u.w, 4 )

    for grp in xrange(grps):
        memcpy( mm.b, msg2+os, 64)
        for q in xrange(4):
            abcd[q] = h[q]
        for p in xrange(4):
            fctn = ff[p]
            rotn = rots[p]
            m = M[p]; o= O[p]
            for q in xrange(16):
                g = (m*q + o) % 16
                f = abcd[1] + rol( abcd[0]+ fctn(abcd) + k[q+16*p] + mm.w[g], rotn[q%4])

                abcd[0] = abcd[3]
                abcd[3] = abcd[2]
                abcd[2] = abcd[1]
                abcd[1] = f
        for p in xrange(4):
            h[p] += abcd[p]
        os += 64
    # return h
