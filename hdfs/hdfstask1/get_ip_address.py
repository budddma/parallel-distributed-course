import sys
import subprocess

def get_ip_address(filename):

	res = subprocess.Popen(['hdfs', 'fsck', filename, '-files' ,'-blocks', '-locations'], 
							stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
	stdout = res.communicate()[0]
	text = stdout.decode("utf-8").split("\n")

	key_line = ''
	for line in text:
		if line[:2] == '0.' and 'DatanodeInfoWithStorage[' in line:
			key_line = line
			break
			
	if key_line:
		ip_start = key_line.find('DatanodeInfoWithStorage[') + len('DatanodeInfoWithStorage[')
		ip_end = ip_start + key_line[ip_start:].find(':')
		return key_line[ip_start:ip_end]


filename = sys.argv[1]
ip = get_ip_address(filename)
print(ip) if ip else print("IP-адрес не найден")    