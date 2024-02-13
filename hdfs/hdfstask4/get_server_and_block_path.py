import sys
import subprocess

def get_server_name(block_id):

	res = subprocess.Popen(['hdfs', 'fsck', '-blockId', block_id, '2>/dev/null'], 
							stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	stdout = res.communicate()[0]
	text = stdout.decode("utf-8").split("\n")
	text.reverse()

	key_line = ''
	for line in text:
		if 'Block replica' in line:
			key_line = line
			break
			
	if key_line:
		server_start = key_line.find(': ') + 2
		server_end = server_start + key_line[server_start:].find('/')
		return key_line[server_start:server_end]
	

def get_block_path(block_id, server):
	ssh_dest = 'hdfsuser@' + server
	res = subprocess.Popen(['sudo', '-u', 'hdfsuser', 'ssh', ssh_dest, 'find', '/', '2>/dev/null', '-name', block_id],
							stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	stdout = res.communicate()[0]
	text = stdout.decode("utf-8").split("\n")
	return text[0]


block_id = sys.argv[1]
server = get_server_name(block_id)
if server:
	path = get_block_path(block_id, server)
	print(server + ':' + path)
else:
	print("Блок не найден")