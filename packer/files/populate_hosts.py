from boto3 import client
from urllib import request
import subprocess

ec2_client = client("ec2", region_name='eu-west-2')

def get_ip(value: str) -> str:
    response = ec2_client.describe_instances(Filters=[
        {
            'Name': 'tag:k8',
            'Values': [
                value,
            ]
        },
        {
            'Name': 'instance-state-name',
            'Values': [
                'running',
            ]
        },
    ])

    if len(response["Reservations"]) > 0:
        return f'{response["Reservations"][0]["Instances"][0]["PrivateIpAddress"].replace("-", ".")}'
    else:
        return ''

server_hosts_entry = ''
node_0_hosts_entry = ''
node_1_hosts_entry = ''

server_ip = get_ip('server')   
if len(server_ip) > 0:
    server_hosts_entry =  f'{server_ip} server.kubernetes.local server\n'

node_0_ip = get_ip('node-0')   
if len(node_0_ip) > 0:
    node_0_hosts_entry =  f'{node_0_ip} node-0.kubernetes.local node-0\n'

node_1_ip = get_ip('node-1')   
if len(node_0_ip) > 0:
    node_1_hosts_entry =  f'{node_1_ip} node-1.kubernetes.local node-1\n'


etc_string = ''

with open("/etc/hosts", "r") as f:

    Lines = f.readlines()
    for line in Lines:
        if '# Kubernetes The Hard Way' in line:
            break
        else:
            etc_string += f'{line}'

    etc_string += '# Kubernetes The Hard Way\n'

    if len(server_hosts_entry) > 0:
        etc_string += server_hosts_entry

    if len(node_0_hosts_entry) > 0:
        etc_string += node_0_hosts_entry

    if len(node_1_hosts_entry) > 0:
        etc_string += node_1_hosts_entry

with open("/etc/hosts", "w") as f:
    f.write(etc_string)


meta_token_request = request.Request(
    url='http://169.254.169.254/latest/api/token', 
    headers={'X-aws-ec2-metadata-token-ttl-seconds': 21600},
    method='PUT')

meta_token = request.urlopen(meta_token_request).read()

instance_id_request = request.Request(url='http://169.254.169.254/latest/meta-data/instance-id', 
    headers={'X-aws-ec2-metadata-token': meta_token},
    method='GET')

instance_id = request.urlopen(instance_id_request).read().decode('utf-8')

tags = ec2_client.describe_tags(Filters=[
    {
        'Name': 'resource-id',
        'Values': [
            instance_id
        ]
    }])['Tags']


for tag in tags:
    if tag['Key'] == 'k8':
        instance_type = tag['Value']

if instance_type == 'server':
    subprocess.run(f'ip route add 10.200.0.0/24 via {node_0_ip}', shell = True, executable="/bin/bash")
    subprocess.run(f'ip route add 10.200.1.0/24 via {node_1_ip}', shell = True, executable="/bin/bash")
elif instance_type == 'node-0':
    subprocess.run(f'ip route add 10.200.1.0/24 via {node_1_ip}', shell = True, executable="/bin/bash")
elif instance_type == 'node-1':
    subprocess.run(f'ip route add 10.200.0.0/24 via {node_0_ip}', shell = True, executable="/bin/bash")