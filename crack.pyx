from libc.stdlib cimport malloc
from libc.string cimport strcat, strcpy, strlen, strcmp

from mymd5 cimport md5


def main():
    cdef char* HASH_TO_CRACK = '357805da9e703e1a9eb2e76200f121f2'
    cdef char** words
    cdef long i, TOTAL_PAIRS
    cdef char* word1
    cdef char* word2
    cdef char* sentence
    cdef int len_w1
    cdef char* start_w2

    with open('words.txt', 'rb') as f:
        words_py = [x.strip() for x in f.readlines()]

    words_py[2000:] = []

    print "num words: %d" % len(words_py)

    NUM_WORDS = len(words_py)
    TOTAL_PAIRS = NUM_WORDS ** 2

    words = <char**> malloc(NUM_WORDS * sizeof(char*))
    for i in range(NUM_WORDS):
        words[i] = words_py[i]

    sentence = <char*> malloc(20000 * sizeof(char))

    i = 0
    for word1 in words[:NUM_WORDS]:
        len_w1 = strlen(word1)
        start_w2 = sentence + len_w1 + 1

        sentence[0] = <char> 0
        strcat(sentence, word1)
        strcat(sentence, ' ')

        for word2 in words[:NUM_WORDS]:
            start_w2[0] = <char> 0
            strcat(start_w2, word2)

            md5(sentence, strlen(word2))
            # tmp = hashlib.md5(sentence).hexdigest()
            # if strcmp(tmp, HASH_TO_CRACK) == 0:
            # if hashlib.md5(sentence).hexdigest() == HASH_TO_CRACK:
                # return word1, word2


            # if i % 1000000 == 0:
            #     print("%.2f%% (%d) TOTAL_PAIRS = %d" % (100 * ((<float>i) / TOTAL_PAIRS), i, TOTAL_PAIRS))
            # i += 1
