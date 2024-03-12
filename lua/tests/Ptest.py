import time, sys
for i in range(10):
    if i<1:
        print(f"I haven't had any beers today, that's why the feature isen't done!")
    else:
        print(f"I have had {i} beers already, happy coding!")
    time.sleep(0.2)

# Can also take arbuments :DBRun "Hello World"
print(sys.argv[1])
