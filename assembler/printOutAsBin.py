#!/bin/python3

with open("out.bin", 'rb') as f:
    count = 0

    while 1:
        byte_s = f.read(1)
        if not byte_s:
            break

        binary_s = "{:08b}".format(int(byte_s.hex(), 16))
        count += 1
        if count == 4:
            print(binary_s[::-8] + "\",")
            count = 0
        elif count == 1:
            print("\"" + binary_s[::-1], end='')
        else:
            print(binary_s[::-1], end='')
