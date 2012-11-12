import os
import time

from msg import send_message


EMAIL_ADDR = "Erik Allik <eallik@gmail.com>"
INPUT_DIR = 'somedir'
DONE_DIR = 'done'


def main():
    if not os.path.exists('done'):
        os.mkdir('done')

    while True:
        files = os.listdir('somedir')

        if len(files) > 0:
            for file in files:
                infile = os.path.join(INPUT_DIR, file)
                print("Sending %s to %s" % (infile, EMAIL_ADDR))
                send_message(infile, EMAIL_ADDR)

                default_outfile = os.path.join(DONE_DIR, file)
                outfile = default_outfile

                suffix = 1
                while os.path.exists(outfile):
                    name, ext = os.path.splitext(default_outfile)
                    outfile = '%s.%d%s' % (name, suffix, ext)
                    suffix += 1

                os.rename(infile, outfile)

        time.sleep(1.0)


main()
