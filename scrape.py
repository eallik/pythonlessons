import sys
import urllib.request


if len(sys.argv) != 3:
    print("Command requires exactly 2 argument")
    sys.exit(1)

url = sys.argv[1]
word = sys.argv[2]

webpage = urllib.request.urlopen(url)

c = 0

for line in webpage.readlines():
    line = line.decode('latin1')
    if word in line:
        c += 1

print("Found {0} lines with '{1}' in it".format(c, word))

webpage.close()
