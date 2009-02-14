def to_signed(value, width):
    value &= ((1 << width) - 1)
    if value < 0:
        if value >= - (1 << (width - 1)):
            return value
        else:
            print "to_signed error"
            return 0
    else:
        if value < (1 << (width - 1)):
            return value
        elif value < (1 << (width)):
            value -= (1 << width)
            return value
        else:
            print "to_signed error"
            return 0

def to_unsigned(value, width):
    if value >= 0:
        value &= ((1 << width) - 1)
    else:
        while value < 0:
            value = (1 << width) + value
    return value
