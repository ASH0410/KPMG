object1 = {"a":{"b":{"c":"d"}}}


def get_all_values(object1):
    for key,value in object1.items():
       # isinstance complare the value and dictionary or not
        if isinstance(value, dict):
            for p in get_all_values(value):
                yield from get_all_values(value)
        else:
            yield value
    
all_pairs = list(get_all_values(object1))
for p in all_pairs:
    print("Value", p)
    print("Values", all_pairs)