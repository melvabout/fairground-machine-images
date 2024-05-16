from boto3 import client

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
        return f'{response["Reservations"][0]["Instances"][0]["PrivateIpAddress"].replace("-", ".")} {value}.kubernetes.local {value}\n'
    else:
        return ''
    
server = get_ip('server')
node_0 = get_ip('node-0')
node_1 = get_ip('node-1')

etc_string = ''

with open("/etc/hosts", "r") as f:

    Lines = f.readlines()
    for line in Lines:
        if '# Kubernetes The Hard Way' in line:
            break
        else:
            etc_string += f'{line}'

    etc_string += '# Kubernetes The Hard Way\n'

    if len(server) > 0:
        etc_string += server

    if len(node_0) > 0:
        etc_string += node_0

    if len(node_1) > 0:
        etc_string += node_1

with open("/etc/hosts", "w") as f:
    f.write(etc_string)