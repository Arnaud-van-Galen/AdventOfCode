import numpy as np
data_ = np.array([199, 200, 208, 210, 200, 207, 240, 269, 260, 263])
data_ = np.loadtxt("01-1-Input.txt")
print(np.sum((np.diff(data_) >0)))