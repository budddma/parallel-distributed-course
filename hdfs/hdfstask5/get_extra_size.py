import sys
import subprocess
import os
import re

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


def get_block_size(block_id):
    server = get_server_name(block_id)
    path = get_block_path(block_id, server)
    res = subprocess.Popen([
        "sudo", "-u", "hdfsuser", "ssh", 'hdfsuser@' + server , "wc", "-c", path], 
		stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout = res.communicate()[0]
    size = stdout.decode("utf-8").split(" ")[0]
    return int(size)

file_size = sys.argv[1]

os.system("dd if=/dev/zero of=temp.bin" + " bs=" + file_size + " count=1" + " > /dev/null 2>&1")
os.system("hdfs dfs -D dfs.replication=1 -put temp.bin > /dev/null 2>&1")

block_data = subprocess.getoutput("hdfs fsck /user/hjudge/temp.bin -files -blocks")
blocks = re.findall(r"blk_[^_]*", block_data)

full_size = 0
for block in blocks:
    full_size += get_block_size(block)

print(full_size - int(file_size))
