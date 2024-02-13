import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

files = [
    '01-add', 
	'02-mul', 
	'03-matrix-add', 
	'04-matrix-vector-mul', 
	'05-scalar-1red', 
	'05-scalar-2red',
	'06-cosine-vector',
	'07-matrix-mul'
]

for file in files:

	data = pd.read_csv('data/' + file + '.txt', sep=' ', header=None, names=['N', 'BlokSize', 'time']).sort_values(by=['BlokSize', 'N'])
	BlokSize_uniq = np.unique(data['BlokSize'].to_numpy())

	plt.figure(figsize=(10, 6))

	for BlokSize in BlokSize_uniq:
		arr = data[data['BlokSize'] == BlokSize][['N', 'time']]
		plt.plot(arr['N'], arr['time'], label=f'BlokSize={BlokSize}')

	plt.title('Зависимость времени вычисления от размера вектора')
	plt.xlabel('N')
	plt.ylabel('Время')
	plt.legend()
	plt.savefig('graphics/' + file + '.png')
