from matplotlib import pyplot as plt
import pandas as pd

data = pd.read_csv("data.txt", sep=' ', header=None, names=['N', 'p', 'S'])

data1 = data[data['N'] == 1000]
data2 = data[data['N'] == 1000000]
data3 = data[data['N'] == 100000000]

plt.figure(figsize=(10, 6))
plt.plot(data1['p'], data1['S'], label="N = 1000", marker='o')
plt.plot(data2['p'], data2['S'], label="N = 1'000'000", marker='o')
plt.plot(data3['p'], data3['S'], label="N = 100'000'000", marker='o')

plt.xlabel('Количество процессов p')
plt.ylabel('Ускорение S')
plt.title('Зависимость ускорения S от количества процессов p')
plt.legend()
plt.grid(True)

plt.savefig('graphic.png')